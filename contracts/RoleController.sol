pragma solidity 0.5.17;

// This file is modified from weidentity-contract.
// We add the roles of enterprizes, asset providers and aggregators(future work).
//
// Copyright© (2018-2019) WeBank Co., Ltd.
//
// The weidentity-contract library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// The weidentity-contract library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with the weidentity-contract library. If not, see <http://www.gnu.org/licenses/>.

/**
 * @title RoleController
 */
contract RoleController {
    uint256 public constant SUCCESS = 0;
    uint256 public constant ERROR_NO_PERMISSION = 10000;

    uint256 public constant ROLE_ADMIN = 100;
    uint256 public constant ROLE_ENTERPRISE = 101;
    uint256 public constant ROLE_PROVIDER = 102;

    uint256 public constant MODIFY_ADMIN = 200;
    uint256 public constant MODIFY_ENTERPRIZE = 201;
    uint256 public constant MODIFY_PROVIDER = 202;
    uint256 public constant MODIFY_OP = 203;
    uint256 public constant MODIFY_ASSET = 204;
    uint256 public constant MODIFY_AUTHORIZE = 205;
    uint256 public constant MODIFY_TASK = 206;

    uint256 private constant ROLE_EXISTS = 1001;

    mapping(address => bool) private isAdmin;
    mapping(address => bool) private isEnterprize;
    mapping(address => bool) private isProvider;

    event RoleAdded(address _id, uint256 _role, uint256 indexed _code);

    constructor() public {
        isAdmin[msg.sender] = true;
    }

    /**
     * @dev checkPermission
     *      checks operation permission for given id/role.
     * @param id refers to caller identifier
     * @param operation refers to the certain function
     * @return permitted or not.
     */
    function checkPermission(address id, uint256 operation)
        public
        view
        returns (bool)
    {
        if (operation == MODIFY_ADMIN) {
            if (isAdmin[id]) {
                return true;
            }
        }
        if (operation == MODIFY_OP) {
            if (isAdmin[id]) {
                return true;
            }
        }
        if (operation == MODIFY_ENTERPRIZE) {
            if (isAdmin[id]) {
                return true;
            }
        }
        if (operation == MODIFY_PROVIDER) {
            if (isAdmin[id]) {
                return true;
            }
        }
        if (operation == MODIFY_ASSET) {
            if (isEnterprize[id]) {
                return true;
            }
        }
        if (operation == MODIFY_AUTHORIZE) {
            if (isProvider[id]) {
                return true;
            }
        }
        if (operation == MODIFY_TASK) {
            if (isEnterprize[id]) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev checkRole
     *      checks id-role pair.
     * @param id refers to identifier
     * @param role refers to the certain role
     * @return bool.
     */
    function checkRole(address id, uint256 role) public view returns (bool) {
        if (role == ROLE_ADMIN) {
            return isAdmin[id];
        }
        if (role == ROLE_ENTERPRISE) {
            return isEnterprize[id];
        }
        if (role == ROLE_PROVIDER) {
            return isProvider[id];
        }
        return false;
    }

    /**
     * @dev addRole
     *      adds role for given id.
     * @param id refers to identifier
     * @param role refers to the certain role
     */
    function addRole(address id, uint256 role) public {
        if (checkRole(id, role)) {
            emit RoleAdded(id, role, ROLE_EXISTS);
            return;
        }
        if (role == ROLE_ADMIN) {
            if (checkPermission(tx.origin, MODIFY_ADMIN)) {
                isAdmin[id] = true;
                emit RoleAdded(id, role, SUCCESS);
            }
        }
        if (role == ROLE_ENTERPRISE) {
            if (checkPermission(tx.origin, MODIFY_ENTERPRIZE)) {
                isEnterprize[id] = true;
                emit RoleAdded(id, role, SUCCESS);
            }
        }
        if (role == ROLE_PROVIDER) {
            if (checkPermission(tx.origin, MODIFY_PROVIDER)) {
                isProvider[id] = true;
                emit RoleAdded(id, role, SUCCESS);
            }
        }
        emit RoleAdded(id, role, ERROR_NO_PERMISSION);
    }
}
