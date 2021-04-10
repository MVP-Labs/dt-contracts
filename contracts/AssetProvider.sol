pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;

// Copyright 2021 The dt-contracts Authors
// This file is part of the dt-contracts library.
//
// The dt-contracts library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// The dt-contracts library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with the dt-contracts library. If not, see <http://www.gnu.org/licenses/>.

import "./RoleController.sol";

/**
 * @title AssetProvider
 */
contract AssetProvider {
    uint256 private constant SUCCESS = 0;
    uint256 private constant ENTERPRIZE_EXISTS = 2001;
    uint256 private constant ENTERPRIZE_NOT_EXISTS = 2002;
    uint256 private constant PROVIDER_EXISTS = 2003;
    uint256 private constant PROVIDER_NOT_EXISTS = 2004;

    struct Enterprize {
        address identity;
        string name;
        string desc;
    }

    struct Provider {
        address identity;
        uint256 reputation;
    }

    mapping(address => Enterprize) enterprizeList;
    mapping(address => Provider) providerList;

    event EnterprizeRegistered(
        address indexed _id,
        string indexed _name,
        string _desc,
        uint256 indexed _code
    );

    event ProviderAdded(address indexed _id, uint256 indexed _code);

    RoleController private rc;

    /**
     * @dev constructor
     *      contract deployment
     * @param rcAddr refers to the RoleController address
     */
    constructor(address rcAddr) public {
        rc = RoleController(rcAddr);
    }

    /**
     * @dev registerEnterprize
     *      registers new enterprize on-chain by the admin.
     * @param _id refers to the enterprize identifier
     * @param _name refers to the enterprize name
     * @param _desc refers to the enterprize description
     */
    function registerEnterprize(
        address _id,
        string memory _name,
        string memory _desc
    ) public {
        if (!rc.checkPermission(msg.sender, rc.MODIFY_ENTERPRIZE())) {
            emit EnterprizeRegistered(
                _id,
                _name,
                _desc,
                rc.ERROR_NO_PERMISSION()
            );
            return;
        }

        if (!rc.checkRole(_id, rc.ROLE_ENTERPRIZE())) {
            rc.addRole(_id, rc.ROLE_ENTERPRIZE());
        }

        if (isEnterprize(_id)) {
            emit EnterprizeRegistered(_id, _name, _desc, ENTERPRIZE_EXISTS);
            return;
        }

        enterprizeList[_id] = Enterprize({
            identity: _id,
            name: _name,
            desc: _desc
        });

        emit EnterprizeRegistered(_id, _name, _desc, SUCCESS);
    }

    /**
     * @dev updateEnterprize
     *      updates the enterprize on-chain by the admin.
     * @param _id refers to the enterprize identifier
     * @param _name refers to the enterprize name
     * @param _desc refers to the enterprize description
     */
    function updateEnterprize(
        address _id,
        string memory _name,
        string memory _desc
    ) public {
        if (!rc.checkPermission(msg.sender, rc.MODIFY_ENTERPRIZE())) {
            emit EnterprizeRegistered(
                _id,
                _name,
                _desc,
                rc.ERROR_NO_PERMISSION()
            );
            return;
        }

        if (!isEnterprize(_id)) {
            emit EnterprizeRegistered(_id, _name, _desc, ENTERPRIZE_NOT_EXISTS);
            return;
        }

        enterprizeList[_id] = Enterprize({
            identity: _id,
            name: _name,
            desc: _desc
        });

        emit EnterprizeRegistered(_id, _name, _desc, SUCCESS);
    }

    /**
     * @dev addProvider
     *      adds new provider on-chain by the enterprize.
     * @param _id refers to the provider identifier
     */
    function addProvider(address _id) public {
        if (!rc.checkPermission(msg.sender, rc.MODIFY_PROVIDER())) {
            emit ProviderAdded(_id, rc.ERROR_NO_PERMISSION());
            return;
        }

        if (!rc.checkRole(_id, rc.ROLE_PROVIDER())) {
            rc.addRole(_id, rc.ROLE_PROVIDER());
        }

        if (isProvider(_id)) {
            emit ProviderAdded(_id, PROVIDER_EXISTS);
            return;
        }

        providerList[_id] = Provider({identity: _id, reputation: 0});

        emit ProviderAdded(_id, SUCCESS);
    }

    /**
     * @dev updateProvider
     *      update the provider on-chain by the enterprize.
     * @param _id refers to the provider identifier
     */
    function updateProvider(address _id) public {
        if (!rc.checkPermission(msg.sender, rc.MODIFY_PROVIDER())) {
            emit ProviderAdded(_id, rc.ERROR_NO_PERMISSION());
            return;
        }

        if (!isProvider(_id)) {
            emit ProviderAdded(_id, PROVIDER_NOT_EXISTS);
            return;
        }

        providerList[_id] = Provider({identity: _id, reputation: 0});

        emit ProviderAdded(_id, SUCCESS);
    }

    /**
     * @dev isProvider
     *      checks provider role.
     * @param _id refers to the address identifier
     * @return bool.
     */
    function isProvider(address _id) public view returns (bool) {
        return providerList[_id].identity == _id;
    }

    /**
     * @dev isEnterprize
     *      checks enterprize role.
     * @param _id refers to the address identifier
     * @return bool.
     */
    function isEnterprize(address _id) public view returns (bool) {
        return enterprizeList[_id].identity == _id;
    }

    /**
     * @dev getEnterprizebyId
     *      returns the enterprize records.
     * @param _id refers to the enterprize identifier
     * @return Enterprize struct.
     */
    function getEnterprizebyId(address _id)
        public
        view
        returns (string memory name, string memory desc)
    {
        require(isEnterprize(_id));

        name = enterprizeList[_id].name;
        desc = enterprizeList[_id].desc;
    }

    /**
     * @dev getIssuerNames
     *      returns the list of names of issuers/enterprizes.
     * @param _idx refers to the enterprize identifiers
     * @return string[].
     */
    function getIssuerNames(address[] memory _idx)
        public
        view
        returns (string[] memory names)
    {
        for (uint i = 0; i < _idx.length; i++) {
            names[i] = enterprizeList[_idx[i]].name;
        }
    }
}
