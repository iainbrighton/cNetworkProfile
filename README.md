Included Resources
==================
* cNetworkLocationProfile
* cNetworkAdapterProfile

cNetworkLocationProfile
================
Configures a network location profile to either the Private or Public profile.

###Syntax
```
cNetworkLocationProfile [string]
{
    Name = [string]
    Profile = [string] { Private | Public }
}
```
###Properties
* Name: The __network location name__ to change. This support wildcard patterns, e.g. 'Network*' or 'Network ?'.
* Profile: The network location profile to apply. __Domain joined network locations cannot be changed.__

###Configuration
```
Configuration cNetworkLocationProfileExample {
    Import-DscResource -ModuleName cNetworkProfile
    cNetworkLocationProfile Network2Private {
        Name = 'Network 2'
        Profile = 'Private'
    }
}
```

cNetworkAdapterProfile
================
Configures a network location profile to either the Private or Public profile by the network adapter name. __This resource requires Windows 2012 and later.__

###Syntax
```
cNetworkAdapterProfile [string]
{
    Name = [string]
    Profile = [string] { Private | Public }
}
```
###Properties
* Name: The __network adapter name__ to change. This support wildcard patterns, e.g. 'Network*' or 'Network ?'.
* Profile: The network location profile to apply. __Domain joined network locations cannot be changed.__

###Configuration
```
Configuration cNetworkAdapterProfileExample {
    Import-DscResource -ModuleName cNetworkProfile
    cNetworkAdapterProfile vEthernetInteralPrivate {
        Name = 'vEthernet (Internal)'
        Profile = 'Private'
    }
}
```