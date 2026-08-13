package com.youtong.controller;

import com.youtong.common.CrudController;
import com.youtong.entity.User;
import com.youtong.service.UserService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/user")
public class UserController extends CrudController<User, Long> {
    public UserController(UserService service) {
        super(service, "status", new String[]{"name", "code", "phone"});
    }
}
