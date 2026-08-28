package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.youtong.common.CrudController;
import com.youtong.common.R;
import com.youtong.entity.CustomerService;
import com.youtong.entity.Store;
import com.youtong.entity.SysAccount;
import com.youtong.service.CustomerServiceService;
import com.youtong.service.DataVersionService;
import com.youtong.service.StoreService;
import com.youtong.service.SysAccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/service")
public class ServiceController extends CrudController<CustomerService, Long> {
    private final CustomerServiceService serviceService;

    @Autowired
    private StoreService storeService;

    @Autowired
    private SysAccountService accountService;

    public ServiceController(CustomerServiceService service, DataVersionService dataVersionService) {
        super(service, "status", new String[]{"name", "phone"}, "service", dataVersionService);
        this.serviceService = service;
    }

    /** C 端服务列表（公开） */
    @GetMapping("/list")
    public R cList(@RequestParam(defaultValue = "1") Integer page,
                   @RequestParam(defaultValue = "10") Integer pageSize) {
        Page<CustomerService> p = new Page<>(page, pageSize);
        QueryWrapper<CustomerService> qw = new QueryWrapper<>();
        qw.eq("status", 1).orderByDesc("id");
        p = serviceService.page(p, qw);
        return R.ok(R.page(p.getTotal(), p.getRecords(), p.getCurrent(), p.getSize()));
    }

    /** 列表填充所属门店名称与绑定工作台账号名 */
    @Override
    protected void fillExtra(List<CustomerService> records) {
        if (records == null || records.isEmpty()) return;

        List<Long> storeIds = records.stream()
                .map(CustomerService::getStoreId)
                .filter(id -> id != null && id > 0).distinct().toList();
        Map<Long, String> storeNames = storeIds.isEmpty() ? Map.of() : storeService.listByIds(storeIds).stream()
                .collect(Collectors.toMap(Store::getId, Store::getName, (a, b) -> a));

        List<Long> accountIds = records.stream()
                .map(CustomerService::getAccountId)
                .filter(id -> id != null && id > 0).distinct().toList();
        Map<Long, String> accountNames = accountIds.isEmpty() ? Map.of() : accountService.listByIds(accountIds).stream()
                .collect(Collectors.toMap(SysAccount::getId,
                        acc -> acc.getNickname() != null && !acc.getNickname().isBlank()
                                ? acc.getNickname() + "（" + acc.getUsername() + "）" : acc.getUsername(),
                        (a, b) -> a));

        for (CustomerService cs : records) {
            if (cs.getStoreId() != null && cs.getStoreId() > 0) {
                cs.setStoreName(storeNames.get(cs.getStoreId()));
            } else {
                cs.setStoreName("全平台（官方客服）");
            }
            if (cs.getAccountId() != null && cs.getAccountId() > 0) {
                String name = accountNames.isEmpty() ? null : accountNames.get(cs.getAccountId());
                cs.setAccountName(name != null ? name : "账号 #" + cs.getAccountId());
            } else {
                cs.setAccountName("未绑定");
            }
        }
    }
}
