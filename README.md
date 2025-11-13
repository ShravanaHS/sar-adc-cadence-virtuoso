# SAR ADC Design Project: Theory & Fundamentals


## 1. Introduction to Data Conversion

### Why Do We Need Data Converters?

The physical world is **analog**. Signals like temperature, pressure, sound, and velocity are continuous. To measure these, we use **transducers**, which convert a physical signal into an electrical (analog) signal.

However, analog signals have significant drawbacks:
* **Susceptible to Noise:** Any interference can easily corrupt the signal.
* **Difficult to Process:** Complex operations like filtering or analysis are complex to implement in the analog domain.
* **Difficult to Store:** Storing an analog value (like a specific voltage) accurately over time is very challenging.

This is why we convert them into the **digital domain**. Digital signals are robust, easy to process with CPUs/DSPs, and can be stored perfectly (as 1s and 0s) without loss.

### The Complete Signal Chain

The process of moving between the analog and digital worlds relies on two key components: the **ADC** and the **DAC**.

* **Analog-to-Digital Converter (ADC):** Converts a real-world analog voltage into a digital number.
* **Digital-to-Analog Converter (DAC):** Converts a digital number back into an analog voltage.

A typical data processing system looks like this:


1.  **Analog Signal:** The real-world physical quantity (e.g., sound).
2.  **Transducer:** A microphone converts the sound into an analog electrical signal.
3.  **ADC:** The ADC samples and quantizes this electrical signal, turning it into a stream of digital bits.
4.  **Digital Processing:** A Digital Signal Processor (DSP) or microcontroller processes these bits (e.g., applies a filter, compresses the data).
5.  **DAC:** The processed bits are sent to a DAC to convert them back into an analog electrical signal.
6.  **Actuator:** An analog component (like a speaker) uses this signal to reproduce the original sound.
---

## High-level ADC/DAC Block Diagram
```mermaid
graph LR;
    A[Sensor] --> B(Anti-alias filter);
    B --> C[Sample & Hold];
    C --> D[ADC];
    D --> E[Digital Processing];
    E --> F[DAC];
    F --> G(Reconstruction Filter);
    G --> H[Actuator];
```
## 2. Basic Concepts

### 2.1 Analog vs. Digital Signals

* **Analog Signals:** An analog signal is **continuous** in both time and amplitude. It can have an infinite number of values within a given range (e.g., the voltage from a microphone, which can be 1.1V, 1.101V, 1.101001V, etc.).
    * **Advantages:** Represents the "real world" perfectly; high resolution.
    * **Disadvantages:** Highly susceptible to noise, difficult to store perfectly, and complex to process.

* **Digital Signals:** A digital signal is **discrete** in both time and amplitude. It is represented by a sequence of numbers (usually binary 0s and 1s).
    * **Advantages:** High noise immunity, perfect storage and replication, and easy to process with computers.
    * **Disadvantages:** The conversion from analog introduces **quantization error**, meaning some information is always lost.


<p align="center">
  <img src="https://www.researchgate.net/publication/324804130/figure/fig1/AS:620040592293889@1524840605847/analogdigitalwave.png" alt="Analog vs. Digital signal waveform">
</p>



### 2.2 Sampling

Sampling is the first step in A/D conversion. It's the process of converting a continuous-time analog signal into a discrete-time signal by taking "snapshots" of it at regular intervals.

* **Sampling Theorem (Nyquist-Shannon Theorem):** To perfectly reconstruct an analog signal, the sampling frequency ($F_s$) must be at least **twice** the highest frequency component ($F_{max}$) in the signal.
    * **Formula:** $F_s \ge 2 \cdot F_{max}$
* **Aliasing:** If you sample too slowly ($F_s < 2 \cdot F_{max}$), higher frequencies "fold down" and disguise themselves as lower frequencies, causing distortion. This is called aliasing.
    
* **Anti-Aliasing Filter:** To prevent aliasing, we always use a **Low-Pass Filter (LPF)** before the ADC. This filter cuts off any frequencies *above* $F_{max}$ (usually $F_s / 2$) to ensure the Nyquist criterion is met.


### 2.3 Quantization

Quantization is the second step. It's the process of mapping the *infinite* possible values of the sampled analog signal to a *finite* set of discrete levels.

* **Quantization Levels:** For an **n-bit** ADC, you have $2^n$ available levels.
    * *Example:* A 3-bit ADC has $2^3 = 8$ levels.
* **LSB (Least Significant Bit):** This is the smallest change the ADC can detect. It's the voltage step size between two adjacent levels. It defines the ADC's **resolution**.
    * **Formula:** $\text{LSB} = \frac{V_{FSR}}{2^n}$
    * $V_{FSR}$ is the Full-Scale Range (e.g., $V_{ref\_max} - V_{ref\_min}$).
    * *Example:* For a 3-bit ADC with a 10V $V_{FSR}$, the $\text{LSB} = \frac{10\text{V}}{2^3} = \frac{10\text{V}}{8} = 1.25\text{V}$.
* **Quantization Error:** This is the inherent error introduced by this "rounding" process. It's the difference between the actual analog input and the quantized level.
    * The maximum error is always $\pm 0.5 \text{ LSB}$. This is an unavoidable part of A/D conversion.

    
<p align="center">
  <img src="https://files.codingninjas.in/article_images/image-sampling-and-quantization-6-1646637756.jpg" alt="Analog vs. Digital signal waveform">
</p>


### 2.4 Encoding

Encoding is the final step. Each discrete quantization level is assigned a unique **binary code**.

* **Binary Representation:** The $2^n$ levels are typically represented by an n-bit binary number.
    * *Example:* For our 3-bit, 8-level ADC:
        * Level 0 (0V) $\rightarrow$ `000`
        * Level 1 (1.25V) $\rightarrow$ `001`
        * ...
        * Level 7 (8.75V) $\rightarrow$ `111`
* **MSB (Most Significant Bit):** The first bit, which represents the largest voltage step (in a SAR ADC, this is $V_{FSR} / 2$).
* **LSB (Least Significant Bit):** The last bit, which represents the smallest voltage step (the resolution).

  > simple [matlab code](https://github.com/ShravanaHS/sar-adc-cadence-virtuoso/edit/main/codes) to simulate these 4 steps

## 3. Sample and Hold (S/H) Circuit

### 3.1 Why is an S/H Circuit Needed?

An ADC takes a finite amount of time to perform its conversion (this is the "Conversion Time"). For our SAR ADC, this is $N$ clock cycles.

If the analog input voltage **changes** during this conversion time, the ADC will be confused. It might compare the input against the MSB at one voltage (e.g., 5.1V) and against the LSB at another (e.g., 5.6V). This leads to a completely incorrect digital code.

The **Sample and Hold (S/H) circuit** solves this. Its job is to:
1.  **Sample:** "Track" the analog input.
2.  **Hold:** "Freeze" the voltage at a specific instant and hold it perfectly steady, giving the ADC a stable input to convert.

It sits directly at the input of the ADC.

### 3.2 Block Diagram

There are two main architectures.

**1. Basic (Open-Loop):**
This is the simplest form, consisting of just a switch and a capacitor.
```mermaid
graph LR
    A(Vin) --> B[Switch];
    B --> C[Hold Capacitor, Ch];
    C --> D(Vout to ADC);
```

**2. Buffered (Closed-Loop):**
This is a more practical design. Your notes mentioned this using op-amps (buffers) to solve impedance problems.
* The first buffer gives a low **source impedance**, allowing it to drive the hold capacitor $C_h$ quickly.
* The second buffer provides a high **input impedance**, which prevents the ADC from "sucking" charge out of the capacitor. This minimizes **droop**.
```mermaid
graph LR
    A(Vin) --> B[Buffer 1];
    B --> C[Switch];
    C --> D[Hold Capacitor, Ch];
    D --> E[Buffer 2];
    E --> F(Vout to ADC);
```


### 3.3 Components

* **MOS Switch:** A simple CMOS transistor (or transmission gate) acts as the electronic switch. When `ON` (Sample mode), it has a low resistance. When `OFF` (Hold mode), it has a very high resistance.
* **Hold Capacitor ($C_h$):** This is the most critical component. It's the "bucket" that stores the analog voltage.
* **Buffers:** (Usually op-amps) Used to isolate the capacitor from the input and output.

### 3.4 Key S/H Parameters

These specifications (from your notes) define how well the S/H circuit works.

* **Acquisition Time:** The time required (after the switch turns ON) for the hold capacitor $C_h$ to charge up to the input voltage $V_{in}$ within a specified error (e.g., within 0.5 LSB). This depends on the switch's `ON` resistance and the size of $C_h$.
  > How long it takes for the hold capacitor ($C_h$) to "fill up" to the input voltage ($V_{in}$).
  
* **Aperture Time:** The time delay between when the "Hold" command is given and when the switch *actually* opens.
  > The small delay between when you command the switch to open and when it actually opens.
  
* **Hold Mode Settling Time:** The time it takes for the output to settle to its final value after the switch opens.
  > The time it takes for the "splash" (Hold Step) to die down.
  
* **Hold Step (or Pedestal Error):** When the switch turns OFF, it "injects" a small amount of charge ($Q$) from its channel into the capacitor. This causes a small, abrupt voltage error.
  > When you turn the switch OFF, it's like a small "splash" that changes the voltage you just captured.
    * **Formula:** $\Delta V = Q / C_h$
    
* **Droop Rate:** The "leaking" of voltage from the capacitor when in Hold mode. This is caused by tiny leakage currents from the `OFF` switch and the buffer's input.
  > The "frozen" voltage on $C_h$ is leaking out, like a bucket with a tiny hole.
    * **Formula:** $\text{Droop Rate} = I_{\text{leakage}} / C_h$
    * **Critical Project Goal:** The total voltage droop during one *full ADC conversion* must be less than 0.5 LSB.
      
* **Feedthrough:** The fraction of the input signal that "leaks" through the `OFF` switch and appears at the output.
  > When the switch is OFF (in "Hold" mode), the fast-changing $V_{in}$ on one side still "wiggles" the $V_{out}$ on the other side.

### 3.5 S/H Design Challenges

There is a fundamental trade-off in choosing the capacitor size $C_h$:

* **Large $C_h$:**
    * **Good:** Low droop rate, small hold step (error).
    * **Bad:** Long acquisition time (slow), requires a strong input buffer.
* **Small $C_h$:**
    * **Good:** Very fast acquisition time.
    * **Bad:** High droop rate, large hold step (error).

The design challenge is to pick a $C_h$ that is **just large enough** to keep the droop rate below 0.5 LSB for our ADC's total conversion time, while still being **small enough** to meet our speed (sampling rate) target.

## 4. DAC Theory

### 4.1 What is a DAC?

A **Digital-to-Analog Converter (DAC)** performs the exact opposite operation of an ADC. It takes a digital binary code (like `1011`) and converts it into a single, specific analog voltage or current.

A DAC is a critical building block *inside* our SAR ADC. The SAR logic "guesses" a digital code, and the DAC creates the analog "test voltage" based on that code.

### 4.2 DAC Parameters

* **Resolution (n):** The same as an ADC. An n-bit DAC has $2^n$ possible input codes and $2^n$ corresponding output voltage levels.
* **Accuracy:** Measures how close the *actual* analog output is to the *ideal* theoretical output.
* **INL / DNL (Integral & Differential Non-Linearity):**
    * **DNL:** Measures the error in "step size" between any two adjacent digital codes. A DNL of 0 LSB is perfect. A DNL of -1 LSB means the DAC is **non-monotonic** (its output might go *down* when the code goes *up*), which is a critical failure.
    * **INL:** Measures the *cumulative* deviation of the entire DAC transfer curve from a perfect straight line.
* **Settling Time:** The time it takes for the DAC's output to change from one value to a new value and "settle" within a specified error band (e.g., $\pm 0.5 \text{ LSB}$). **This is critical for a SAR ADC**, as the DAC must settle *every clock cycle*.
* **Glitch Impulse:** When the DAC switches from one code to another (e.g., `0111` to `1000`), the digital logic delays can cause a brief, large "glitch" or "spike" in the analog output. This must be minimized.

### 4.3 Types of DAC

This section covers the two most common DAC architectures used inside ADCs.

#### 4.3.1 Binary Weighted DAC

This is the most intuitive design. It uses an op-amp in an "inverting summer" configuration.

* **Working:** It has a set of resistors and switches. For an n-bit DAC, you have resistors with values **R, 2R, 4R, 8R, ... $2^{n-1}R$**.
* The digital code (e.g., `1010`) controls switches to connect these resistors to a reference voltage ($V_{ref}$).
* The op-amp then "sums" the currents flowing from $V_{ref}$ through these weighted resistors. If the MSB (with resistor R) is ON, it contributes the most current. If the LSB (with resistor $2^{n-1}R$) is ON, it contributes the least current.



* **Transfer Function:** $V_{out} = - \frac{R_f}{R} \cdot (b_3 \cdot V_{ref}) - \frac{R_f}{2R} \cdot (b_2 \cdot V_{ref}) - \frac{R_f}{4R} \cdot (b_1 \cdot V_{ref}) - \dots$
    (Where $b_i$ is the digital bit, '1' or '0').
* **Advantages:**
    * Very simple to understand and design.
* **Disadvantages:**
    * **Requires a huge range of resistor values.** For a 10-bit DAC, you would need $R$ and $512R$. This is *impossible* to manufacture accurately on a chip. The $512R$ resistor would be physically enormous, and matching $R$ to $512R$ would be a nightmare.
    * For this reason, it's almost never used for resolutions above 4 or 5 bits.

#### 4.3.2 R-2R Ladder DAC

This is the *most popular* DAC architecture for SAR ADCs. It cleverly solves the resistor-matching problem.

* **Working:** This DAC only uses **two** resistor values: R and 2R. It creates a special "ladder" network.
* **Ladder Explanation:** The magic of the R-2R ladder is that at *any* "node" (joint) in the ladder, the resistance looking "down" to ground is 2R, and the resistance looking "left" or "right" (per Thevenin's theorem) is R.
* This structure creates a perfect **binary-weighted voltage division** at each node, or **binary-weighted current division** depending on the configuration.
* Digital switches (controlled by the bits $b_0, b_1, \dots$) route these currents to an op-amp, which sums them to create the $V_{out}$.



* **Why R-2R is Preferred:**
    * **Only 2 Resistor Values:** This is a *massive* advantage in VLSI. It's much easier to manufacture and **match** many copies of R and 2R than to create a huge range (like R and 512R).
    * **Good Matching = Good Linearity:** Because all resistors can be well-matched (e.g., by making them from identical small segments), the R-2R DAC has excellent linearity (low INL/DNL).
    * **This is the DAC we will most likely use (or its cousin, the Capacitive DAC) in our SAR project.**

### 4.4 DAC Transfer Characteristics

The "transfer curve" of a DAC is a graph of all its possible outputs.
* The X-axis is the digital input code (e.g., 0 to 255 for 8 bits).
* The Y-axis is the analog output voltage.
* In a perfect DAC, this graph is a **perfectly straight staircase**. Each step is exactly 1 LSB wide and 1 LSB high.
* **INL** measures how much the "corner" of each step deviates from the perfect straight line.
* **DNL** measures the *height* of each individual step.



### 4.5 Example Calculation (4-bit R-2R DAC)

Let's find the output voltage for a 4-bit R-2R DAC.
* **Givens:**
    * $n = 4$ bits (16 levels)
    * $V_{ref} = 5.0\text{ V}$
    * Digital Input Code = `1011`
* **Formula:** The output voltage for an R-2R DAC is:
    $V_{out} = V_{ref} \cdot (\frac{\text{Digital Code}}{2^n})$
* **Calculation:**
    1.  Convert the binary code to a decimal number:
        `1011` $\rightarrow (1 \cdot 2^3) + (0 \cdot 2^2) + (1 \cdot 2^1) + (1 \cdot 2^0) = 8 + 0 + 2 + 1 = 11$
    2.  Calculate the total number of levels:
        $2^n = 2^4 = 16$
    3.  Plug into the formula:
        $V_{out} = 5.0\text{ V} \cdot (\frac{11}{16}) = 5.0\text{ V} \cdot 0.6875 = 3.4375\text{ V}$

So, the digital code `1011` corresponds to an analog output of 3.4375V.
