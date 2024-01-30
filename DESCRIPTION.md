## LocalSend

LocalSend is a cross-platform app that enables secure communication between devices using a REST API and HTTPS encryption. Unlike other messaging apps that rely on external servers, LocalSend doesn't require an internet connection or third-party servers, making it a fast and reliable solution for local communication.

LocalSend uses a secure communication protocol that allows devices to communicate with each other using a REST API. All data is sent securely over HTTPS, and the TLS/SSL certificate is generated on the fly on each device, ensuring maximum security.

For more information on the LocalSend Protocol, see the [documentation](https://github.com/localsend/protocol).

![LocalSend Screenshot](https://cdn.jsdelivr.net/gh/brogers5/chocolatey-package-localsend.install@3f4aecbffec6b5f802027e5d928f1738ffd982bf/Screenshot.png)

## Package Notes

The installer package requires use of Windows 10 version 2004 or later due to its use of [StartupTasks](https://learn.microsoft.com/en-us/uwp/schemas/appxpackage/uapmanifestschema/element-desktop-startuptasks) in the app package manifest. If you require support for an earlier operating system, consider using the [portable version](https://community.chocolatey.org/packages/localsend.portable) of this package instead.
