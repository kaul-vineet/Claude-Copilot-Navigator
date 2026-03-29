import * as vscode from 'vscode';
import * as cp from 'child_process';
import * as path from 'path';

const ENVIRONMENTS = ['Development', 'Test', 'UAT', 'Sandbox', 'Production'];

export function activate(context: vscode.ExtensionContext) {
    const outputChannel = vscode.window.createOutputChannel('Navigator');

    context.subscriptions.push(
        vscode.commands.registerCommand('navigator.quickDeploy', () =>
            runDeploy(context, 'Quick', outputChannel)
        )
    );

    context.subscriptions.push(
        vscode.commands.registerCommand('navigator.fullMigration', () =>
            runDeploy(context, 'Full', outputChannel)
        )
    );
}

export function deactivate() {}

async function runDeploy(
    context: vscode.ExtensionContext,
    mode: 'Quick' | 'Full',
    outputChannel: vscode.OutputChannel
): Promise<void> {
    const modeLabel = mode === 'Quick' ? 'Quick Deploy' : 'Full Migration';

    // Collect bot name — required because Read-Host hangs in a non-TTY process
    const botName = await vscode.window.showInputBox({
        title: `Navigator: ${modeLabel}`,
        prompt: 'Bot name to deploy',
        placeHolder: 'e.g. Sales Assistant'
    });
    if (botName === undefined) {
        return; // User pressed Escape
    }

    // Collect target environment
    const target = await vscode.window.showQuickPick(ENVIRONMENTS, {
        title: `Navigator: ${modeLabel}`,
        placeHolder: 'Select target environment'
    });
    if (!target) {
        return; // User pressed Escape
    }

    // Resolve script path relative to extension install location
    const scriptPath = path.join(
        context.extensionPath,
        '..',
        'skills',
        'navigator',
        'scripts',
        'Invoke-Navigator-Enhanced.ps1'
    );

    const args = [
        '-ExecutionPolicy', 'Bypass',
        '-NonInteractive',
        '-File', scriptPath,
        '-Mode', mode,
        '-Target', target,
        '-NoConfirm'
    ];

    if (botName.trim()) {
        args.push('-BotName', botName.trim());
    }

    outputChannel.clear();
    outputChannel.show(true); // preserve editor focus
    outputChannel.appendLine(`Navigator ${modeLabel} → ${target}${botName ? ` (${botName})` : ''}`);
    outputChannel.appendLine('─'.repeat(50));

    let outputBuffer = '';

    try {
        await vscode.window.withProgress(
            {
                location: vscode.ProgressLocation.Notification,
                title: `Navigator: ${modeLabel} → ${target}`,
                cancellable: false
            },
            async (progress) => {
                progress.report({ message: 'Starting...' });

                return new Promise<void>((resolve, reject) => {
                    const proc = cp.spawn('pwsh', args, {
                        cwd: path.dirname(scriptPath),
                        windowsHide: true,
                        stdio: ['ignore', 'pipe', 'pipe'] // close stdin to prevent Read-Host hang
                    });

                    proc.stdout!.on('data', (data: Buffer) => {
                        const text = data.toString();
                        outputBuffer += text;
                        outputChannel.append(text);

                        if (text.includes('[1/3]')) {
                            progress.report({ message: 'Getting copilot from source...' });
                        } else if (text.includes('[2/3]')) {
                            progress.report({ message: 'Deploying to target...' });
                        } else if (text.includes('[3/3]')) {
                            progress.report({ message: 'Publishing...' });
                        }
                    });

                    proc.stderr!.on('data', (data: Buffer) => {
                        outputChannel.append('[stderr] ' + data.toString());
                    });

                    proc.on('close', (code) => {
                        code === 0
                            ? resolve()
                            : reject(new Error(`Process exited with code ${code}`));
                    });

                    proc.on('error', (err) => {
                        reject(new Error(
                            `Failed to start pwsh: ${err.message}. ` +
                            `Ensure PowerShell 7 is installed (https://aka.ms/powershell).`
                        ));
                    });
                });
            }
        );

        // Extract test URL from output for Quick Deploy button
        const urlMatch = outputBuffer.match(/https:\/\/copilotstudio\.microsoft\.com\/[^\s]+/);
        const testUrl = urlMatch ? urlMatch[0] : null;

        const actions: string[] = ['Show Output'];
        if (testUrl && mode === 'Quick') {
            actions.unshift('Open Test Chat');
        }

        const selected = await vscode.window.showInformationMessage(
            `Navigator: ${modeLabel} to ${target} complete.`,
            ...actions
        );

        if (selected === 'Open Test Chat' && testUrl) {
            vscode.env.openExternal(vscode.Uri.parse(testUrl));
        } else if (selected === 'Show Output') {
            outputChannel.show();
        }

    } catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        const selected = await vscode.window.showErrorMessage(
            `Navigator: Deployment failed. ${message}`,
            'Show Output'
        );
        if (selected === 'Show Output') {
            outputChannel.show();
        }
    }
}
