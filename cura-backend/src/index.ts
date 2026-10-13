import app from './app';
import { env } from './config/env';

const port = env.PORT || 3000;

app.listen(port, () => {
  console.log(`CuraTrail Proxy Server is running on port ${port}`);
});
