/**
 * @type {import('next').NextConfig}
 */
module.exports = {
  swcMinify: true,
  reactStrictMode: true,
  // We will make sure that output is statics
  output: 'standalone',
  async rewrites() {
    return [
      {
        source: '/s/:snapshotId',
        destination: '/api/sameorigin/:snapshotId',
      },
      { source: '/r/:snapshotId', destination: '/api/share/:snapshotId' },
    ];
  },
};
