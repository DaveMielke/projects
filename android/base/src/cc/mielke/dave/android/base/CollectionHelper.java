package cc.mielke.dave.android.base;

import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;

import java.util.Set;
import java.util.HashSet;
import java.util.ArrayList;

import java.io.File;

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

  public static void sortByPath (ArrayList<File> files) {
    Comparator<File> comparator =
      new Comparator<File>() {
        @Override
        public int compare (File file1, File file2) {
          return file1.getAbsolutePath().compareTo(file2.getAbsolutePath());
        }
      };

    if (ApiTests.HAVE_ArrayList_sort) {
      files.sort(comparator);
    } else {
      Collections.sort(files, comparator);
    }
  }
}
