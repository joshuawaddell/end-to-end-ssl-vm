# Configuring end-to-end TLS with Application Gateway and Internet Information Services

This is a Bicep implementation of <https://techcommunity.microsoft.com/t5/fasttrack-for-azure/walkthrough-configuring-end-to-end-tls-with-application-gateway/ba-p/3269132>

## Prerequisites

To deploy this example scenario, the following is necessary:

- Azure Subscription
- Custom Domain Name
- DNS
- Wildcard Certificate (PFX)

### Azure Subscription

This example scenario requires an Azure Subscription, and it supports Pay-As-You-Go, Enterprise, and MSDN/Visual Studio Subscriptions. The resources in this sample do incur charges, but some resources may be deallocated to save on costs.

### Custom Domain Name

This example scenario requires a custom domain name which will be used as the host name in the Azure Application Gateway Listener and the Internet Information Services Site Binding Host Name.

### DNS

This example scenario requires access to DNS hosting services for the custom domain name. After deployment, it is necessary to create A Records for the two websites created.

### Certificate Services

This example scenario utilizes a Wildcard SSL Certificate to secure the Azure Application Gateway Listener and the Internet Information Services Site Binding Host Name. The Wildcard PFX must have a password set. There are multiple online services, such as [Let's Encrypt](https://letsencrypt.org/getting-started/), that provide free and low-cost SSL Certificates.

## Deployment

To deploy this example scenario, clone the repository to your local machine using Git. From the local repository folder, execute the `Deploy-EndToEndSslVm.ps1` file, and enter the parameter values requested. You will be prompted for the following parameter values at the time of deployment:

| Parameter                 | Type   | Description                                                                                                                                    |
| ------------------------- | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `location`                | string | Azure Region for deployment Environment (e.g. `eastus`)|
| `resourceGroupName`       | string | Name of the Azure Resource Group for deployment (e.g `rg-end2endsslvm`)|
| `keyVaultName`            | string | Name of the Azure Key Vault (e.g. `kv-end2endsslvm`)*|
| `$managedIdentityName`    | string | The name of the Azure User-Assigned Managed Identity (e.g. `id-end2endsslvm`)|
| `pfxCertificatePath`      | string | The path to the PFX Certificate (e.g. `C:\certificates\wildcard.pfx`)|
| `certificatePassword`     | secureString | The password to the PFX certificate (e.g. `P@ssword123`)|
| `base64Path`              | string | The path to the Base64 Certificate export (e.g. `C:\certificates\wildcard.txt`)|
| `adminPassword`           | secureString | The password to the Virtual Machine Administrator account (e.g. `P@ssword123`)|
| `adminUserName`           | string | The name of the Administrator user (e.g. `resourceadmin`|
| `domainName`              | string | The name of the Custom Domain (e.g. `mydomain.com`|

_*Note: Some Azure Resources, such as Key Vault, require globally unique names across the Azure Namespace. Using the example name provided will most likely result in a failed deployment. Customize the name of the Azure Kay Vault._

## Postrequisites

### Internet Information Services Configuration

#### Certificate Installation

To install the PFX Certificate to the Internet Information Server:

1. From Windows Administrative Tools, open Internet Information Services (IIS) Manager
2. Select the IIS Server (vm-end2endsslvm), and open the Server Certificates Feature

![Alt text](https://raw.githubusercontent.com/joshuawaddell/end-to-end-ssl-vm/main/images/iis_manager_server_certificates_1.jpg "a title")

### DNS Update

Insert text here
