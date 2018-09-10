## Generating NFV Scripts

In OSP10, first-boot script for multiple roles require many manual
modifications. Recently with latest OSP10 minor release with ovs29
support, role-specific first-boot can be provided. With this feature,
and aligning to OSP13 parameter style, following modifications are done:

1. OVS-DPDK service name has been renamed as `ComputeNeutronOvsDpdk` in
   roles_data.yaml and appropriate mapping has been added in the dpdk-
   registry.j2.yaml file.

2. Added a generate script similar to the tripleo-common implementation in
   OSP10, so that first-boot scripts could be generated based on the
   roles_data.yaml input, with below commands:

    ```bash
    python generate.py -r roles_data.yaml -i first-boot.role.j2.yaml
    python generate.py -r roles_data.yaml -i dpdk-registry.j2.yaml
    ```

   NOTE: Compute roles with word "Compute" will have the first-boot scripts
   mapped in the dpdk- registry.j2.yaml file

3. Parameters name have been updated to OSP13 naming

4. Parameters input style is also aligned with OSP13 style, like

    ```yaml
    ComputeOvsDpdkParameters:
      KernelArgs: "intel_iommu=on iommu=on default_hugepagesz=1GB hugepagesz=1G hugepages=64 isolcpus=10-87"
      IsolCpusList: "10-87"
      OvsPmdCoreList: "10,11,22,23"
      OvsDpdkCoreList: "0,1,2,3,4,5,6,7,8,9"
      OvsDpdkSocketMemory: "1024,1024"
    ```

    NOTE: Providing `KernelArgs` will apply the kernel args and tuned profile.
    And providing `OvsPmdCoreList` will apply the OVS-DPDK config in the
    first-boot.sh script with appropriate conditions. With this, same first-
    boot could be used for both OVS-DPDK and SR-IOV by differentiating with
    input parameters.

5. Implicit way of adding `isolcpus` has been removed from first-boot and now
   it has to be added to the `KernelArgs` parameter explicity.
