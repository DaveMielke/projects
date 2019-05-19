package cc.mielke.dave.android.base;

import java.util.Arrays;
import java.util.Collections;

import java.util.Set;
import java.util.HashSet;
import java.util.ArrayList;

public abstract class CollectionHelper {
  private CollectionHelper () {
  }

  public static <TYPE> Set<TYPE> toUnmodificableSet (TYPE... values) {
    return Collections.unmodifiableSet(new HashSet<TYPE>(Arrays.asList(values)));
  }

  public static <TYPE> TYPE removeRandomElement (ArrayList<TYPE> list) {
    if (list.isEmpty()) return null;
    int index = (int)Math.round(Math.floor((double)list.size() * Math.random()));
    return list.remove(index);
  }
}
