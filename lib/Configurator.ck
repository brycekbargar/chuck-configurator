public class Configurator
{
  fun static void Configure(string args[])
  {
    for(0 => int i; i < args.size() - 1; 2 +=> i )
    {
      args[i] => string key;
      args[i + 1] => string value;

      ObjectFactory.Use(key, value);
    }
  }
}
