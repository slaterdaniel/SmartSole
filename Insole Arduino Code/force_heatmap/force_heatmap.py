import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import numpy as np
import serial
from time import sleep

# plt.style.use('fivethirtyeight')

ser = serial.Serial('/dev/cu.usbmodem1101', 115200, timeout=0)
MAX = 40

def update(i):
    try:
        line = ser.readline().strip()[:-1].split(b",")
        ser.reset_input_buffer()

        lih = list(map(int, line))
        data = np.reshape(lih, (6, 2))[::-1]
        plt.cla()
        plt.imshow(data, cmap='Blues', vmin=-10, vmax=MAX, interpolation='lanczos', interpolation_stage='rgba')  # hamming, lanczos
    except KeyboardInterrupt:
        print("Closing Serial Port...")
        ser.close()
    except:
        pass
ani = FuncAnimation(plt.gcf(), update, interval=16, cache_frame_data=False, save_count=5)

plt.tight_layout()
plt.show()