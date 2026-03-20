import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext): void {
  context.subscriptions.push(
    vscode.debug.registerDebugAdapterDescriptorFactory('pc1500', {
      createDebugAdapterDescriptor(
        session: vscode.DebugSession
      ): vscode.ProviderResult<vscode.DebugAdapterDescriptor> {
        const config = session.configuration;
        const port: number = config.port || 3756;
        const host: string = config.host || 'localhost';
        return new vscode.DebugAdapterServer(port, host);
      },
    })
  );
}

export function deactivate(): void {
  // Nothing to clean up.
}
