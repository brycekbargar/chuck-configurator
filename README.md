# The Configurator #
A pseudo DI factory for the [ChucK language](http://chuck.cs.princeton.edu/).

### Usage ###

##### Registering with the ObjectFactory #####
You can register any type as part of the `ObjectFactory` by calling the `Register` static method. For example:

```
public class ThingBase { }
public class JustAThing extends ThingBase { }
public class SuperCoolThing extends ThingBase { }

ObjectFactory.Register("JustAThing", new JustAThing);
ObjectFactory.Register("SuperCoolThing", new SuperCoolThing);
```

*Note: since ChucK (as far as I know) doesn't have reflection,
registration uses magic strings and and concrete instances.
You should be careful that what you register won't interfere with normal execution by
handling/creating events or by using a large chuck of memory.*

##### Getting Instances #####
The `ObjectFactory` has two non-public methods `_GetInstance` and `_GetConfiguredInstance`.
Since these are non-public you will have to sub-class the `ObjectFactory` with your own strongly-typed implementation.
For example:

```
public class ThingFactory extends ObjectFactory
{
  fun ThingBase GetConfiguredThing()
  {
    return _GetConfiguredInstance("Thing") $ ThingBase;
  }

  fun SuperCoolThing GetSuperCoolThing()
  {
    return _GetInstance("SuperCoolThing") $ SuperCoolThing;
  }

  fun JustAThing GetJustAThing()
  {
    return _GetInstance("JustAThing") $ JustAThing;
  }

  static ThingFactory @ _thingFactory;
  fun static ThingFactory Instance()
  {
    if(_thingFactory == null)
    {
      new ThingFactory @=> _thingFactory;
    }
    return _thingFactory;
  }
}
ThingFactory.Instance();
```

*Note: I'm fairly unhappy with the whole registration/retrieval thing
so it is fairly likely to change in an upcoming release*

##### Configuring the implementations #####
Before/During/After `ObjectFactory` registration you can set the default implementations.
This is done by calling the `UseDefault` static method. For example:

```
// Note: "Thing" is pretty arbitrary. It could be "things", or "t" or even "I miss reflection..."
ObjectFactory.UseDefault("Thing", "SuperCoolThing");
```

The default implementation will only be used if a non-default implementation is not chosen. For example:

```
ObjectFactory.UseDefault("Thing", "SuperCoolThing");

ThingFactory.Instance().GetConfiguredThing() // returns SuperCoolThing implementation
```

```
ObjectFactory.UseDefault("Thing", "SuperCoolThing");
ObjectFactory.Use("Thing", "JustAThing");
ObjectFactory.UseDefault("Thing", "SuperCoolThing");

ThingFactory.Instance().GetConfiguredThing() // returns JustAThing implementation
```

##### The Configurator #####
Basically just a wrapper for code I found myself commonly writing around configuration and DI. It has a single static method `Configure` which parses an options array and configures the `ObjectFactory`. For example:

```
[ "Thing", "JustAThing",
  "AnotherKey", "AnotherValue" ] @=> string args[];
Configurator.Configure(args);

/*  ObjectFactory will have received the following calls
*   ObjectFactory.Use("Thing", "JustAThing");
*   ObjectFactory.Use("AnotherKey", "AnotherValue");
*/
```

This makes it easy to configure ChucK from the command line. For example:
```
string args[0];
for(int i; i < me.args(); i++)
{
  args << me.arg(i);
}

Configurator.Configure(args);
```
