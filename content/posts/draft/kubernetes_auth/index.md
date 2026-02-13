---
title: Kubernetes 访问控制
date: 2026-01-14
lastmod: 2026-01-14
draft: true
tags:
- Kubernetes
---

Kubernetes 文档中关于访问控制的内容散落在各处，看着十分头大。因此，我决定写一篇博客来系统性地介绍一下。

## Authentication

k8s 中有两类用户，service accounts 和 normal users。

### normal users

一个人类管理员通过 kubeconfig 访问集群就属于 normal user。

k8s 假设有一个外部服务来管理 normal users，因此，在 k8s 没有用来表示 normal user 的 object。那 k8s 如何进行 authn 呢？方法很多。在我们的 kubeconfig 中最常见的是通过 client certificates 的方式。流程如下：

- 通过 k8s 集群的 CA 证书签发一个客户端证书，这一步通常由 k8s 部署工具（如 kubeadm）完成，各大云平台上的 k8s 托管集群也会自动完成这一步
-  client 通过集群的 CA 证书，客户端证书和私钥和 apiserver 进行 tls 握手。这里是 mTLS 的流程，两边都会校验对方的证书。
- apiserver 验证证书合法后，通过证书中的 commonName 提取出用户名。至此认证结束

我们可以用 curl 实验一下，认证确实是通过 TLS 完成的：

```bash
$ curl -k "https://127.0.0.1:55595/api/v1/namespaces"
[403 error, User \"system:anonymous\" cannot list resource \"namespaces\" in API group \"\" at the cluster scope]
$ kubectl config view --raw \
  -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' \
  | base64 --decode > ca.crt
$ kubectl config view --raw \
  -o jsonpath='{.users[0].user.client-certificate-data}' \
  | base64 --decode > client.crt
$ kubectl config view --raw \
  -o jsonpath='{.users[0].user.client-key-data}' \
  | base64 --decode > client.key
$ kubectl config view --raw \
  -o jsonpath='{.clusters[0].cluster.server}'
https://127.0.0.1:55595
$ curl --cacert ca.crt \
     --cert client.crt \
     --key client.key \
     "https://127.0.0.1:55595/api/v1/namespaces"
[data]
```

### service accounts

service accounts 通常被用于在 Pod 中访问集群资源。这类用户通过一个 token （一个 JWT）来进行认证 ，这个 JWT 将被包含在 HTTP 请求的 `Authorization: Bearer <token>` header 中。

一个 service account 由 k8s 中的 ServiceAccount object 表示。我们可以通过 `kubectl create token <serviceAccountName>` 来手动创建一个 service account token。这个命令请求的 api 为 `/api/v1/namespaces/default/serviceaccounts/<name>/token`，也就是 [TokenRequest API](https://kubernetes.io/docs/reference/kubernetes-api/authentication-resources/token-request-v1/)。解码 JWT Payload 后得：

```json
{
  "aud": [
    "https://kubernetes.default.svc.cluster.local"
  ],
  "exp": 1768385015,
  "iat": 1768381415,
  "iss": "https://kubernetes.default.svc.cluster.local",
  "jti": "11de8bf9-5da9-4ec3-94ae-562f8018c5ab",
  "kubernetes.io": {
    "namespace": "default",
    "serviceaccount": {
      "name": "vault",
      "uid": "e39daf0a-620c-463b-ab3a-a3d03db16179"
    }
  },
  "nbf": 1768381415,
  "sub": "system:serviceaccount:default:vault"
}
```

也可以通过 secret 来创建一个 token：

```bash
$ kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: vault-secret       
  annotations:
    kubernetes.io/service-account.name: vault      
type: kubernetes.io/service-account-token
EOF
secret/vault-secret created
```

token 会自动被添加到这个 secret 中。解码 JWT Payload 后得：

```json
{
  "iss": "kubernetes/serviceaccount",
  "kubernetes.io/serviceaccount/namespace": "default",
  "kubernetes.io/serviceaccount/secret.name": "vault-secret",
  "kubernetes.io/serviceaccount/service-account.name": "vault",
  "kubernetes.io/serviceaccount/service-account.uid": "e39daf0a-620c-463b-ab3a-a3d03db16179",
  "sub": "system:serviceaccount:default:vault"
}
```

可以看到这两种 token 是不一样的，因为调用了不同的 API。通过 Secret 创建 token 是在 Token controller 中处理的。

最常用的方式是在 pod spec 中设置 serviceAccountName 后，由 [ServiceAccount admission controller](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/#serviceaccount-admission-controller) mutate pod spec，加入下面的 volume：

```yaml
...
  - name: kube-api-access-<random-suffix>
    projected:
      sources:
        - serviceAccountToken:
            path: token # must match the path the app expects
        - configMap:
            items:
              - key: ca.crt
                path: ca.crt
            name: kube-root-ca.crt
        - downwardAPI:
            items:
              - fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
                path: namespace
```

然后由 kubelet 通过 TokenRequest API 获取 token，并把相关信息作为 volume 挂载到 pod 中。此时的 token JWT payload 为：

```json
{
  "aud": [
    "https://kubernetes.default.svc.cluster.local"
  ],
  "exp": 1799916338,
  "iat": 1768380338,
  "iss": "https://kubernetes.default.svc.cluster.local",
  "jti": "742c5215-d0ae-4834-8da3-f01ca138cc95",
  "kubernetes.io": {
    "namespace": "default",
    "node": {
      "name": "kubeblocks-control-plane",
      "uid": "4edfef67-6fe8-4424-9b9d-82d9cf4e66d7"
    },
    "pod": {
      "name": "vault-0",
      "uid": "788fbf4b-577b-4f7b-a7c9-b4e9d9fc93ba"
    },
    "serviceaccount": {
      "name": "vault",
      "uid": "e39daf0a-620c-463b-ab3a-a3d03db16179"
    },
    "warnafter": 1768383945
  },
  "nbf": 1768380338,
  "sub": "system:serviceaccount:default:vault"
}
```

可以看到 JWT 的格式和上文手动创建的 token 一致。

在 k8s 1.24 之前，向 pod 中注入的 token 并不是通过 TokenRequest API 生成的，而是由上面的通过 secret 创建 token 的方式生成。这种方式生成的 token 没有有效期（即永久有效），所以不推荐使用了。

由 TokenRequest API 生成的 token 带过期时间，默认是一小时。在 token 过期前 kubelet 会自动刷新 token。

下面手动调用一下 TokenRequest API：

```bash
$ cat << EOF > tokenrequest.yaml
heredoc> {
  "apiVersion": "authentication.k8s.io/v1",
  "kind": "TokenRequest"
}
heredoc> EOF
$ kubectl create -f tokenrequest.yaml --raw "/api/v1/namespaces/default/serviceaccounts/vault/token"  | jq
{
  "kind": "TokenRequest",
  "apiVersion": "authentication.k8s.io/v1",
  "metadata": {
    "name": "vault",
    "namespace": "default",
    "creationTimestamp": "2026-01-14T12:28:06Z",
    "managedFields": [omitted]
  },
  "spec": {
    "audiences": [
      "https://kubernetes.default.svc.cluster.local"
    ],
    "expirationSeconds": 3600,
    "boundObjectRef": null
  },
  "status": {
    "token": "omitted",
    "expirationTimestamp": "2026-01-14T13:28:06Z"
  }
}
```

这里有个和文档不一致的地方。[文档中](https://kubernetes.io/docs/reference/kubernetes-api/authentication-resources/token-request-v1/#TokenRequestSpec) `.spec.audiences` 显示的是 required，实际可以不填。查看[源码](https://github.com/kubernetes/kubernetes/blob/62277ef5d29d2aed692ae8013d5eb289bf75c0b5/pkg/registry/core/serviceaccount/storage/token.go#L117-L119)发现 audience 如果不填的话会默认使用 apiserver 的 audience。

说到这里就要引出另一个机制了，那就是 TokenRequest 生成的 token 不单单可以用来 auth apiserver, 也可以给外部服务用。我们可以在 `.spec.audiences` 中指定另一个服务，这时候生成的 token 将无法用来 auth apiserver。但是，外部服务可以通过 k8s 的 TokenReview API 来验证该 token 的有效性。

## Authorization

k8s 采取的是 RBAC（Role-based access control）模型，每个用户都会被绑定到一个或多个角色中。

- Role: 一组权限
- Subject: 可以是虚拟的 User/Group, 或是 `ServiceAccount` 等
- RoleBinding: Role 和 Subject 的绑定

Role and RoleBinding are namespaced object. When it's cluster wide, use ClusterRole and ClusterRoleBinding.

当一个用户有了 update role 的权限之后，他是不是能够修改这个 role 来扩大自己的权限呢？k8s 中有一项额外的安全措施来防止这一点。这个措施是：只有当用户满足下列任意规则时，才能创建/更新 role：

- 用户已经拥有了他想修改的 role 中的所有权限
- 用户被显式授予了 role/clusterrole 资源的 `escalate` 动词

对于 rolebinding, 规则也是类似的。

## 参考

- [API Access Control](https://kubernetes.io/docs/reference/access-authn-authz/)
- [KEP Bound Service Account Tokens](https://github.com/kubernetes/enhancements/tree/master/keps/sig-auth/1205-bound-service-account-tokens)
- [KEP-4193: bound service account token improvements](https://github.com/kubernetes/enhancements/tree/master/keps/sig-auth/4193-bound-service-account-token-improvements)
