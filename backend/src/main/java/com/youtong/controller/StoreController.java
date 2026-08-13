package com.youtong.controller;

import com.youtong.common.CrudController;
import com.youtong.entity.Store;
import com.youtong.service.StoreService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/store")
public class StoreController extends CrudController<Store, Long> {
    public StoreController(StoreService service) {
        super(service, "status", new String[]{"name", "address"});
    }
}
