# Policy Engine User Flow diagram
![policy engine user flow diagram](./diagrams/PolicyEngine.drawio.svg)

# Identifying Device Types

To enable the network team to identify device types (laptop, printer, etc.), the decision has been made to make use of the Subject Alt Name (SAN) attribute (`TLS-Client-Cert-Subject-Alt-Name-Dns`). This attribute has multiple values and is concatenated in the virtual servers to produce a comma separated list, which can be then be used in the Admin Portal when adding rules for a policy.

### Example

```
DNS.1=moj.test.org.uk
DNS.2=laptop.moj.test.org.uk
```

The concatenated value will be `moj.test.org.uk,laptop.moj.test.org.uk`.
