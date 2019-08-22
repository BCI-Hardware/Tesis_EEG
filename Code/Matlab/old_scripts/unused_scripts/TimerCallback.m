function TimerCallback(TimerH, EventData)
res = 100050;
len = 0.5 * res;
hz = 800;

sound( sin( hz*(2*pi*(0:len)/res) ), res);