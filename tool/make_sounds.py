# Собирает спокойную музыку и звук успеха для игр (без чужих записей и лицензий).
# Запуск: python3 tool/make_sounds.py, затем afconvert в m4a (см. конец файла).
import math, struct, wave, random

RATE = 22050

def write(path, samples):
    with wave.open(path, 'w') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(RATE)
        w.writeframes(b''.join(struct.pack('<h', int(max(-1, min(1, s)) * 32000)) for s in samples))

def note_freq(n):  # n: номер полутона от A4
    return 440.0 * 2 ** (n / 12)

def bell(buf, start, freq, length, amp):
    """Мягкий колокольчик: синус с обертоном и плавным затуханием."""
    s0 = int(start * RATE)
    for i in range(int(length * RATE)):
        t = i / RATE
        env = min(1.0, t / 0.03) * math.exp(-t * 2.2)
        v = math.sin(2 * math.pi * freq * t) + 0.25 * math.sin(2 * math.pi * freq * 2 * t)
        if s0 + i < len(buf):
            buf[s0 + i] += amp * env * v

# Музыка: 32 секунды, медленная пентатоника до мажора и тихий аккорд-подложка.
LEN = 32.0
music = [0.0] * int(LEN * RATE)
random.seed(7)
pent = [-9, -7, -5, -2, 0, 3, 5, 7]  # C4 D4 E4 G4 A4 C5 D5 E5 относительно A4
chords = [[-21, -14, -9], [-16, -9, -4], [-19, -12, -7], [-14, -7, -2]]  # C, F, Am, G-ish
beat = 60 / 54
step = 0
t = 0.0
while t < LEN - 3:
    chord = chords[int(t // (beat * 8)) % len(chords)]
    if step % 8 == 0:
        for n in chord:
            bell(music, t, note_freq(n), beat * 8, 0.06)
    if step % 2 == 0 or random.random() < 0.35:
        bell(music, t, note_freq(random.choice(pent)), 2.8, 0.12)
    t += beat
    step += 1
# Плавные края, чтобы повтор был без щелчка.
fade = int(1.5 * RATE)
for i in range(fade):
    k = i / fade
    music[i] *= k
    music[-1 - i] *= k
peak = max(abs(x) for x in music)
write('assets/audio/calm_music.wav', [x / peak * 0.6 for x in music])

# Звук успеха: две ноты вверх, мягко.
chime = [0.0] * int(1.4 * RATE)
bell(chime, 0.0, note_freq(7), 1.3, 0.35)   # E5
bell(chime, 0.16, note_freq(12), 1.2, 0.35)  # A5
peak = max(abs(x) for x in chime)
write('assets/audio/success.wav', [x / peak * 0.7 for x in chime])
# afconvert -f m4af -d aac -b 64000 assets/audio/calm_music.wav assets/audio/calm_music.m4a
