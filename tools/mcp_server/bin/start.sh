#!/bin/bash
cd "$(dirname "$0")/.."
exec dart run bin/pc1500_mcp_server.dart 2>/dev/null
