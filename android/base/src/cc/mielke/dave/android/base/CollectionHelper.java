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

  public static <ElementType> Set<ElementType> toUnmodificableSet (ElementType... elements) {
    return Collections.unmodifiableSet(new HashSet<ElementType>(Arrays.asList(elements)));
  }

  public static <ElementType> ElementType removeRandomElement (ArrayList<ElementType> list) {
    if (list.isEmpty()) return null;

    int size = list.size();
    int index = (int)Math.round(Math.floor((double)size * Math.random()));
    ElementType element = list.get(index);

    int last = size - 1;
    if (index < size) list.set(index, list.get(last));
    list.remove(last);

    return element;
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
