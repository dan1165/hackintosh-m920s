/*
 * SSDT-RHUB -- only needed when the USB controller's RHUB device blocks
 * macOS from enumerating ports (mostly 400/500-series). For the M920s
 * Cannon Lake PCH this is normally NOT required; ship it disabled and
 * only enable it if USB ports are missing/broken.
 */
DefinitionBlock ("", "SSDT", 2, "ACDT", "Rhub", 0x00000000)
{
    External (_SB_.PCI0.XHC.RHUB, DeviceObj)

    Scope (\_SB.PCI0.XHC.RHUB)
    {
        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            If (_OSI ("Darwin"))
            {
                Return (Zero)
            }
            Else
            {
                Return (0x0F)
            }
        }
    }
}
