package com.youtong.controller;

import com.youtong.common.CrudController;
import com.youtong.entity.CustomerService;
import com.youtong.service.CustomerServiceService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/service")
public class ServiceController extends CrudController<CustomerService, Long> {
    public ServiceController(CustomerServiceService service) {
        super(service, "status", new String[]{"name", "phone"});
    }
}
