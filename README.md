# shibboleth-idp5-containerization
*Attempt at containerization and eventually K8s support for the Shibboleth Identity Provider.*

# Objectives
- Shibbooeth Identity Provider 5
- Jetty 12 (recommended Java servlet runtime)
- Easy configuration injection
- Easy and reproducible builds/upgrades
- *Later* Duo MFA plugin

The naive strategy for this is to build what can be ahead of time, then inject configs and build the rest at runtime. The other idea is to bake configurations into the image, but this would require deployers to maintain their own image.

# Deployment
*Hopefully this works and this section will be updated with information on deploying a production-ready IdP :)*