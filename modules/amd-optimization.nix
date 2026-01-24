{ pkgs, ... }:

{
  boot.kernelParams = [
    # --- CPU & System ---
    "amd_pstate=active"         # AMD P-State driver for better CPU power management
    "iommu=pt"                  # IOMMU passthrough for better performance

    # --- GPU Core Fixes (CRITICAL for 6.18.x on Strix Point) ---
    "amdgpu.gpu_recovery=1"     # Enable GPU recovery from hangs
    "amdgpu.cwsr_enable=0"      # Disable broken CWSR (see: https://bugs.gentoo.org/967078)
    "amdgpu.ip_block_mask=0xfffff7ff"  # Disable VPE (bit 11) - fixes VPE queue reset failures

    # --- Optional: Uncomment if you experience specific issues ---
    # "amdgpu.runpm=0"          # Disable runtime PM (only if suspend/resume issues persist)
    # "amdgpu.gfx_off=0"        # Disable GFX power saving (only if freezes during idle)
    # "amdgpu.dcdebugmask=0x10" # Disable PSR (only if screen flickering with external displays)
  ];

  # Force amdgpu driver early load
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware = {
    enableAllFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # Note: VPE is disabled via kernel params, so hardware video encoding won't work
        # Software encoding via ffmpeg will be used instead
        libva-utils       # VA-API utilities for video acceleration
        vaapiVdpau        # VA-API to VDPAU translation
        libvdpau-va-gl    # VDPAU support

        # Uncomment if you need OpenCL/ROCm support for GPU compute:
        # rocmPackages.clr.icd
      ];
    };
  };

  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # --- FIX AGGIUNTIVO ---
      # Impedisce a TLP di mandare in sleep il bus PCIe della scheda video
      PCIE_ASPM_ON_AC = "performance";
      PCIE_ASPM_ON_BAT = "performance";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
}
