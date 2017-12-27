lowmem_size = @(- *pc* lowmem)

    org @(+ loaded_lowmem lowmem_size)
