package cc.mielke.dave.android.radio;

public abstract class RadioPrograms {
  private RadioPrograms () {
  }

  private final static Object PROGRAM_LOCK = new Object();
  private static RadioProgram currentProgram = null;

  public static RadioProgram get () {
    synchronized (PROGRAM_LOCK) {
      return currentProgram;
    }
  }

  public static void set (RadioProgram program) {
    synchronized (PROGRAM_LOCK) {
      if (currentProgram != null) currentProgram.stop();
      currentProgram = program;
      if (currentProgram != null) currentProgram.start();
    }
  }
}
