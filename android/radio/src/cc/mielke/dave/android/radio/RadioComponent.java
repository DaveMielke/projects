package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseComponent;

import java.util.ArrayList;

public abstract class RadioComponent extends BaseComponent {
  protected RadioComponent () {
    super();
  }

  protected static MusicLibrary getMusicLibrary () {
    return RadioApplication.getMusicLibrary();
  }

  protected static BookLibrary getBookLibrary () {
    return RadioApplication.getBookLibrary();
  }

  protected static RadioPrograms getRadioPrograms () {
    return RadioApplication.getRadioPrograms();
  }

  protected static RadioProgram getRadioProgram () {
    RadioPrograms programs = getRadioPrograms();
    if (programs == null) return null;
    return programs.getProgram();
  }

  protected static RadioPlayer getRadioPlayer () {
    RadioProgram program = getRadioProgram();
    if (program == null) return null;
    return program.getCurrentPlayer();
  }

  protected final <TYPE> TYPE removeRandomElement (ArrayList<TYPE> list) {
    if (list.isEmpty()) return null;
    int index = (int)Math.round(Math.floor((double)list.size() * Math.random()));
    return list.remove(index);
  }
}
