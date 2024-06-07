package org.example.spice;

import java.util.Iterator;
import java.util.PrimitiveIterator;
import java.util.Random;

public class Checker {
    public void check() {
        for (int j = 0; j < 3; j++) {
            var iter = tenRandomInts();
            while (iter.hasNext()) {
                var i = iter.nextInt();
                if (i < 100) {
                    System.out.println("Bongo");
                } else if (i > 200) {
                    System.out.println("Dingo");
                } else {
                    System.out.println("Zapp");
                }
            }
        }
    }

    private static PrimitiveIterator.OfInt tenRandomInts() {
        var randomInts = new Random().ints();
        return randomInts.limit(10).iterator();
    }
}
