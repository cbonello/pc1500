"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.activate = activate;
exports.deactivate = deactivate;
const vscode = require("vscode");
function activate(context) {
    context.subscriptions.push(vscode.debug.registerDebugAdapterDescriptorFactory('pc1500', {
        createDebugAdapterDescriptor(session) {
            const config = session.configuration;
            const port = config.port || 3756;
            const host = config.host || 'localhost';
            return new vscode.DebugAdapterServer(port, host);
        },
    }));
}
function deactivate() {
    // Nothing to clean up.
}
//# sourceMappingURL=extension.js.map