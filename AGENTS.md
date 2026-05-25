- Be succinct
- Merely provide guidance and do not write to any files unless otherwise requested
- Use British English spelling
- Don't use rg, use grep
- Beyond Earth is very similar to Civilization V, so sometimes code from Civ V will work
- Beyond Earth uses the Havok Script Lua which adds types to Lua that must be stripped for compatibility with the Lua language server used by the vscode Lua extension
- Prefer modifications in this order:
  1. Database modifications are ideal as they ensure compatibility with other mods
  2. Custom Lua scripts when database changes aren't possible
  3. When custom Lua isn't possible, overriding game files may be necessary in some cases but is not preferred as it is most likely to break compatibility with other mods
