export default ({ env }) => ({
  upload: {
    config: {
      provider: 'aws-s3',
      providerOptions: {
        baseUrl: env('CDN_URL'),
        rootPath: env('CDN_ROOT_PATH', ''),
        s3Options: {
          // Sin llaves (Lambda) el SDK usa el rol IAM de la función.
          // Se revisa AWS_ACCESS_SECRET porque Lambda ya define AWS_ACCESS_KEY_ID
          ...(env('AWS_ACCESS_SECRET') && {
            credentials: {
              accessKeyId: env('AWS_ACCESS_KEY_ID'),
              secretAccessKey: env('AWS_ACCESS_SECRET'),
            },
          }),
          region: env('AWS_REGION'),
          params: {
            ACL: env('AWS_ACL', 'private'),
            Bucket: env('AWS_BUCKET'),
          },
        },
      },
      actionOptions: {
        upload: {},
        uploadStream: {},
        delete: {},
      },
    },
  },
});
