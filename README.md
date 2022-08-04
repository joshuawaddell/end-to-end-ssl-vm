# Configuring end-to-end TLS with Application Gateway and Internet Information Services

This is a Bicep implementation of <https://techcommunity.microsoft.com/t5/fasttrack-for-azure/walkthrough-configuring-end-to-end-tls-with-application-gateway/ba-p/3269132>

## Prerequisites

To deploy this example scenario, the following services and software must be setup and configured:

- Azure Subscription
- Custom Domain Name
- DNS
- Wildcard Certificate (PFX)

### Azure Subscription

- This example scenario requires an Azure Subscription, and it supports Pay-As-You-Go, Enterprise, and MSDN/Visual Studio Subscriptions. The resources in this sample do incur charges, but some resources may be deallocated to save on costs.

### Custom Domain Name

- This example scenario requires a custom domain name which will be used as the host name in the Azure Application Gateway Listener and the Internet Information Services Site Binding Host Name.

### DNS

- This example scenario requires access to DNS hosting services for the custom domain name. After deployment, it is necessary to create A Records for the two websites created.

### Certificate Services

- This example scenario utilizes a Wildcard SSL Certificate to secure the Azure Application Gateway Listener and the Internet Information Services Site Binding Host Name.
  multiple services including App Services and Application Gateway. The Wildcard PFX must have a password set. There are multiple online services, such as [Let's Encrypt](https://letsencrypt.org/getting-started/), that provide free and low-cost SSL Certificates.

- Prior to deployment, please note the location of the Wildcard Certificate (Example: 'C:\certificates\wildcard.pfx').

## Deployment

Insert text here.

## Postrequisites

Insert text here.
