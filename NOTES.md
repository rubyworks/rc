# Developer Notes


## 2012-04-07 | Toplevel DSLs

If it were not for Ruby's mixing toplevel definitions into all
objects, I likely would have used the simpler design of 
just loading the config files directly (via `#load`).

It's dissapointing that Ruby continues to insist on mixing toplevel
methods into all objects. It would be much easier to write script
DSLs if it did not, saving a good bit of code. In this case, for
instance, I probably could have shaved off 20% to 40% of the 
current code --neither the Config or the Configuration class
would be needed, and the parser could be stripped down to just
enough code to collect a list of profiles since that is all it
would really be useful for then.


## 2012-04-05 | Multiple Configurations

Should multiple definitions for the same tool and profile be
allowed?

    config :qed, :cov do
      ...
    end

    config :qed, :cov do
      ...
    end

    configuration.invoke(:qed, :cov)

Should both definitions be called, or just the later? I have decide
that both will be called. If this becomes a concern, I may add a `#reconfig`
method which would first clear the list of matching configurations.

