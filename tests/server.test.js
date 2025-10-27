const request = require('supertest');
const app = require('../src/server');

describe('GET /', () => {
  it('should return welcome message', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toEqual(200);
    expect(res.body.message).toContain('Node.js DevOps Demo');
  });
});
