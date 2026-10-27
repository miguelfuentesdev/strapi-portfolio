export default ({ env }) => ({
  host: env('HOST', '0.0.0.0'),
  port: env.int('PORT', 1337),
  // Detrás de CloudFront: confiar en X-Forwarded-* para cookies seguras
  proxy: { koa: env.bool('IS_PROXIED', true) },
  url: env('PUBLIC_URL', ''),
  app: {
    keys: env.array('APP_KEYS'),
  },
});
