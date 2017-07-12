import jenkins.model.*
import hudson.security.*
import jenkins.security.*

// Define admin credentials, get Jenkins instance
//def username = args[0]
//def password = args[1]
def instance = Jenkins.getInstance()

// Setup Authorization strategy
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(username,password)
instance.setSecurityRealm(hudsonRealm)
def strategy = new hudson.security.FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)
instance.save()

// Get API-Token
User u = User.get(username)
ApiTokenProperty t = u.getProperty(ApiTokenProperty.class)
def token = t.getApiTokenInsecure()
println "$token"
System.out.println("$token")
