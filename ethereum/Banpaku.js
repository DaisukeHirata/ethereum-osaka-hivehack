import web3 from './web3';
import Banpaku from './build/Banpaku.json';

export default address => {
  return new web3.eth.Contract(JSON.parse(Banpaku.interface), address);
};
