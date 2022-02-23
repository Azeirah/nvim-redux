(variable_declarator 
    value: (call_expression 
        function: 
            (identifier) @fn_name
            (#match? @fn_name "createSlice")
        arguments: (arguments (object (pair
                key: 
                    (property_identifier) @key_name 
                    (#match? @key_name "reducers")
                value: (object [ 
                        (method_definition)
                        (pair value: [(arrow_function) (function)])
                    ] @reducer))))))
