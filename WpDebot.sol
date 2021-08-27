pragma ton-solidity >=0.40.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "Debot.sol";
import "Terminal.sol";
import "Menu.sol";
import "Network.sol";
import "UserInfo.sol";

contract WpDebot is Debot {
    bytes m_icon;
    address m_wallet;

    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }


    function start() public override {
        UserInfo.getAccount(tvm.functionId(setDefaultAccount));
        _menu();
    }
    
    function _menu() private inline {
        Menu.select("Please make your choice", "description for menu", [
            MenuItem("Get authorization code", "", tvm.functionId(handleMenu1)),
            MenuItem("Login to the site", "", tvm.functionId(handleMenu2))
        ]);
    }

    function handleMenu1() public {
        string[] headers;
        string url = "https://domain.com/wp-json/debact/" + format("{}", m_wallet); //Change domain.com
        headers.push("Content-Type: application/x-www-form-urlencoded");
        Network.get(tvm.functionId(setResponse), url, headers);
    }

    function handleMenu2() public {
        Terminal.print(0, "To register on the site, follow the link https://domain.com/rega/"); //Change domain.com
        start();
    }

    function setDefaultAccount(address value) public {
        m_wallet = value;
    }

    function setResponse(int32 statusCode, string[] retHeaders, string content) public {
        require(statusCode == 200, 101);
        if (content == "") {
            Terminal.print(0, "To register on the site, follow the link https://domain.com/login/"); //Change domain.com
        }
        else {
            Terminal.print(0, content);
        }
        start();
    }


    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string caption, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "WP DeBot";
        version = "0.0.1";
        publisher = "weborsha";
        caption = "Login DeBOT for Wordpress";
        author = "Weborsha";
        support = address.makeAddrStd(0, 0x841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94);
        hello = "Hello, i am a WP DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, UserInfo.ID, Network.ID, Menu.ID ];
    }

}