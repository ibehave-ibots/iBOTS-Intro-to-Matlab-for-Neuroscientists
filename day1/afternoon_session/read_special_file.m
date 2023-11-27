classdef read_special_file < matlab.task.LiveTask
    properties(Access = private, Transient)
        EditFieldLabel matlab.ui.control.Label
        EditField matlab.ui.control.EditField
    end
    
    properties(Dependent)
        State
        Summary
    end
    
    methods(Access = protected)
        function setup(task)
            createComponents(task);
        end
    end
    
    methods
        function createComponents(task)
            grid = uigridlayout(task.LayoutManager);
            grid.RowHeight = repmat({'fit'}, 1, 1);
            grid.ColumnWidth = repmat({'fit'}, 1, 2);
            
            % Create EditFieldLabel
            task.EditFieldLabel = uilabel(grid, 'Text', 'choose your file');
            task.EditFieldLabel.Layout.Row = 1;
            task.EditFieldLabel.Layout.Column = 1;
            
            % Create EditField
            nestedGrid = uigridlayout(grid);
            nestedGrid.Layout.Row = 1;
            nestedGrid.Layout.Column = 2;
            nestedGrid.ColumnWidth = {'1x', 30};
            nestedGrid.RowHeight = {'1x'};
            nestedGrid.ColumnSpacing = 5;
            nestedGrid.RowSpacing = 0;
            nestedGrid.Padding = [0 0 0 0];
            task.EditField = uieditfield(nestedGrid, 'Value', "");
            task.EditField.UserData.sourceLiveControlData.valueType = "string";
            task.EditField.Layout.Row = 1;
            task.EditField.Layout.Column = 1;
            exploreButton = uibutton(nestedGrid);
            exploreButton.Text = '...';
            exploreButton.Layout.Row = 1;
            exploreButton.Layout.Column = 2;
            exploreButton.ButtonPushedFcn = @(~, ~, ~) task.getFile(task.EditField);
        end
        
        function [code,outputs] = generateCode(task)
            outputs = {'data_table', 'text_data'};
            codeTemplate = ["file_input = " + task.extractValue(task.EditField) + ";"
                "data_init = readcell(file_input);"
                "counter = 0;"
                "for i = 1:height(data_init)"
                "    if ~isnumeric(data_init{i,1})"
                "        counter = counter + 1;"
                "    end"
                "end"
                "num_text_lines = counter;"
                ""
                "data = readcell(file_input,""NumHeaderLines"",num_text_lines);"
                "header = readcell(file_input);"
                "header= header(1,:);"
                ""
                "data_table = cell2table(data,""VariableNames"",header);"
                "string_cell = readcell(file_input);"
                "text_data=string_cell(1:num_text_lines,:);"
                ""
                ""
                "clear counter string_cell file_input num_text_lines data header data_init i % dont care about these variables"];
            code = join(string(codeTemplate), newline);
        end
        
        function summary = get.Summary(~)
            summary = "Loads in a datafile that has text and numerical data";
        end
        
        function state = get.State(task)
            state = struct;
            state.EditField = task.EditField.Value;
        end
        
        function set.State(task, state)
            task.EditField.Value = state.EditField;
        end
        
        function reset(task)
            task.EditField.Value = '""';
        end
    end
    
    methods(Access = private)
        function getFile(~, widget)
            [name, directory] = uigetfile;
            if name
                widget.Value = append(directory, name);
            end
        end
        
        function out = extractValue(~, widget)
            value = widget.Value;
            type = class(value);
            
            if isfield(widget.UserData, 'sourceLiveControlData')
                type = widget.UserData.sourceLiveControlData.valueType;
            end
            
            switch (type)
                case "string"
                    out = append('"', replace(value, '"', '""'), '"');
                case "double"
                    out = string(value);
                case "char"
                    out = append("'", replace(value, "'", "''"), "'");
                otherwise
                    out = value;
            end
        end
    end
end