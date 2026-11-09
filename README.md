# Focus Rainmeter skin

Rainmeter focus tracker card (25 minute ring, state, keep-working hold).

The skin is a read-only viewer. It polls a single pipe-separated status file
written by a local toolkit; no credentials or account data live here.

## Install

1. Copy this folder into `Documents\Rainmeter\Skins\Focus`.
2. Load `Focus.ini` from the Rainmeter manager.
3. Set your toolkit folder under `[Variables]` in the ini:

   `ini
   ToolsRoot=C:\Tools
   `

   The skin expects its toolkit under `%ToolsRoot%\focus`.
   The Lua helpers, if present, have a `PATH` constant near the top with
   the same value in forward-slash form.
