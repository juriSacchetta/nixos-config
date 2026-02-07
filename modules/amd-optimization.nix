{ pkgs, ... }:

{
  boot.kernelParams = [
    # --- CPU & System ---
    "amd_pstate=active"         # AMD P-State driver for better CPU power management
    "iommu=pt"                  # IOMMU passthrough for better performance

    # --- GPU Core Fixes (CRITICAL for 6.18.x on Strix Point) ---
    "amdgpu.mes=0"              # Disable MES (mitigates "MES ring buffer is full" hangs/log spam)
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
        # Vulkan support (moved from system packages)
        vulkan-loader

        # Video acceleration (Note: VPE disabled, using software encoding)
        libva-utils       # VA-API utilities
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
      # CPU Performance Management
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # AMD-specific: CPU boost behavior
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # Platform profiles (AMD-specific)
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # GPU Power Management (AMD)
      RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
      RADEON_DPM_PERF_LEVEL_ON_BAT = "low";
      RADEON_DPM_STATE_ON_AC = "performance";
      RADEON_DPM_STATE_ON_BAT = "battery";

      # PCIe Active State Power Management
      # Keep GPU PCIe at performance to prevent stability issues
      PCIE_ASPM_ON_AC = "performance";
      PCIE_ASPM_ON_BAT = "performance";

      # USB autosuspend (useful for battery, but exclude input devices)
      USB_AUTOSUSPEND = 1;
      USB_EXCLUDE_BTUSB = 1;  # Don't suspend Bluetooth
      USB_EXCLUDE_PHONE = 1;  # Don't suspend tethered phones

      # Battery Charge Thresholds (40-80% for longevity)
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
}
