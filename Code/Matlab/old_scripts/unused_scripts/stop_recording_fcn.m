function stop_recording_fcn(src, event)
    disp(event.Key);
    disp('Closing current recording. Press CTRL + C to kill it')
    fclose(fid);
    fclose(serial_port);
    
    delete(instrfindall)
end