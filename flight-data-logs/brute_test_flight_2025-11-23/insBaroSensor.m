classdef insBaroSensor < positioning.INSSensorModel
%BAROSENSOR Sensor measuring barometric altitude

    methods 
        function z = measurement(~,filter)
            % Measurement
            pos = stateparts(filter,'Position');
            pos_z = pos(3);
            z = pos_z;
        end
    end
end