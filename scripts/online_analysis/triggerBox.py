import sys; sys.path.append('auxiliaries\pylsl-1.10.3\pylsl') # help python find pylsl relative to this example program
from pylsl import StreamInfo, StreamOutlet
from Tkinter import *
import random
import time

##### LSL stuff ######

# first create a new stream info (here we set the name to MyMarkerStream, the content-type to Markers, 1 channel, irregular sampling rate, and string-valued data)
# The last value would be the locally unique identifier for the stream as far as available, e.g. program-scriptname-subjectnumber (you could also omit it but interrupted connections wouldn't auto-recover).
# The important part is that the content-type is set to 'Markers', because then other programs will know how to interpret the content
info = StreamInfo('triggerBox','Markers',1,0,'string','myuidw43536');

# next make an outlet
outlet = StreamOutlet(info)

print("Now sending markers to LSL...")
markernames = ['Open', 'Close', 'Grasp', 'Pause']

def writeOpenC():
        outlet.push_sample(["cO"])
        time.sleep(.05)
  #      print('Commanded: Open')

def writeCloseC():
        outlet.push_sample(["cC"])
        time.sleep(.05)
  #     print('Commanded: Close')
        
def writeGraspC():
        outlet.push_sample(["cG"])
        time.sleep(.05)
  #     print('Commanded: Grasp')

def writePause():
        outlet.push_sample(["Pause"])
        time.sleep(.05)
   #    print('Commanded: Pause')
   
def writeContinue():
        outlet.push_sample(["Continue"])
        time.sleep(.05)
   #    print('Commanded: Continue')
        
def writeOpenA():
        outlet.push_sample(["aO"])
        time.sleep(.05)
   #    print('Announced: Open')

def writeCloseA():
        outlet.push_sample(["aC"])
        time.sleep(.05)
   #   print('Announced: Close')
        
def writeGraspA():
        outlet.push_sample(["aG"])
        time.sleep(.05)
   #   print('Announced: Grasp')

        


# create the window
root = Tk()

# modify root window
root.title("triggerBox")
#root.geometry("300x400")

app = Frame(root)
app.grid()

#commandLabel = Label(root, text="Command", bg="red", fg="white")
#commandLabel.grid(row=1, column=1)

openButtonC = Button(app, text = "Open (c)", command=writeOpenC, width=15, height=10, bg = 'blue', fg='green')
openButtonC.grid(row=1, column=1)

closeButtonC = Button(app, text = "Close (c)", command=writeCloseC, width=15, height=10, bg = 'red', fg='white')
closeButtonC.grid(row=1, column=2)

graspButtonC = Button(app, text = "Grasp (c)", command=writeGraspC, width=15, height=10, bg = 'green', fg='black')
graspButtonC.grid(row=1, column=3)

#announceLabel = Label(root, text="Announce", bg="red", fg="white")
#announceLabel.grid(row=2,column=1)

openButtonA = Button(app, text = "Open (a)", command=writeOpenA, width=15, height=10,bg = 'blue', fg='green')
openButtonA.grid(row = 2, column=1)

closeButtonA = Button(app, text = "Close (a)", command=writeCloseA, width=15, height=10,bg = 'red', fg='white')
closeButtonA.grid(row = 2, column=2)

graspButtonA = Button(app, text = "Grasp (a)", command=writeGraspA, width=15, height=10,bg = 'green', fg='black')
graspButtonA.grid(row = 2, column=3)


pauseButton = Button(app, text = "Pause", command=writePause, width=15, height=5,bg = 'black', fg='white')
pauseButton.grid(row=3, column=1)

pauseButton = Button(app, text = "Continue", command=writeContinue, width=15, height=5,bg = 'black', fg='white')
pauseButton.grid(row=3, column=2)


root.mainloop()

#while True:
#        # pick a sample to send an wait for a bit
#        outlet.push_sample([random.choice(markernames)])
#        time.sleep(random.random()*3)
