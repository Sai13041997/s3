PS C:\Users\T012sp\Git repo\real-time-insurance-infra> Select-String -Path .github\workflows\*.yml -Pattern 'uses:|tofu_version'

.github\workflows\tofu-apply.yml:17:    uses: kfbmic/tf-action-tooling/.github/workflows/tofu-apply-aws.yml@main
.github\workflows\tofu-apply.yml:21:      tofu_version: latest
.github\workflows\tofu-plan.yml:19:    uses: kfbmic/tf-action-tooling/.github/workflows/tofu-plan-aws.yml@main
.github\workflows\tofu-plan.yml:23:      tofu_version: latest


PS C:\Users\T012sp\Git repo\real-time-insurance-infra>
