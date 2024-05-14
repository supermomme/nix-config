{ lib, ... }: {
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "spotify"
    "obsidian"
    "vscode"
    "nvidia-x11"
    "nvidia-settings"
    "steam"
    "steam-original"
    "steam-run"
    "vagrant"
    "vscode-extension-github-copilot"
    "Oracle_VM_VirtualBox_Extension_Pack"
    "vscode-extension-ms-vscode-remote-remote-containers"
  ];
}