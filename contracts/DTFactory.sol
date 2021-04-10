pragma solidity 0.5.17;

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
 * @title DTFactory
 */
contract DTFactory {
    uint256 private constant SUCCESS = 0;
    uint256 private constant DT_EXISTS = 4001;
    uint256 private constant DT_NOT_EXISTS = 4002;
    uint256 private constant CDT_EXISTS = 4003;
    uint256 private constant CDT_NOT_EXISTS = 4004;
    uint256 private constant DT_GRATED = 4005;
    uint256 private constant DT_NOT_GRATED = 4006;

    struct DataToken {
        bytes32 dt;
        address owner;
        address minter;
        bool isLeaf;
        bytes32 checksum;
        string ipfsPath;
        uint256 blockUpdated;
    }

    // all dts including leaf/composable
    mapping(bytes32 => DataToken) DTLists;
    // dt permission chain
    mapping(bytes32 => mapping(bytes32 => bool)) DTPermissions;
    // available cdts
    mapping(bytes32 => bool) CDTLists;

    bytes32[] public dts;

    event DataTokenMinted(
        bytes32 _dt,
        address indexed _owner,
        address _minter,
        bool _isLeaf,
        bytes32 _checksum,
        string _ipfsPath,
        uint256 _blockUpdated,
        uint256 indexed _code
    );

    event CDTMinted(
        bytes32 indexed _cdt,
        bytes32[] indexed _childDTs,
        uint256 _code
    );

    event DataTokenGranted(
        bytes32 indexed _dt,
        address _owner,
        bytes32 indexed _grantee,
        uint256 indexed _code
    );

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
     * @dev mintDataToken
     *      creates new data token on-chain.
     * @param _dt refers to data token identifier
     * @param _owner refers to data token owner
     * @param _isLeaf leaf dt or composable dt
     * @param _checksum checksum associated with dt/metadata
     * @param _ipfsPath refers to the metadata storage path
     */
    function mintDataToken(
        bytes32 _dt,
        address _owner,
        bool _isLeaf,
        bytes32 _checksum,
        string memory _ipfsPath
    ) public {
        if (!rc.checkPermission(msg.sender, rc.MODIFY_ASSET())) {
            emit DataTokenMinted(
                _dt,
                _owner,
                msg.sender,
                _isLeaf,
                _checksum,
                _ipfsPath,
                block.number,
                rc.ERROR_NO_PERMISSION()
            );
            return;
        }

        if (isDTAvailable(_dt)) {
            emit DataTokenMinted(
                _dt,
                _owner,
                msg.sender,
                _isLeaf,
                _checksum,
                _ipfsPath,
                block.number,
                DT_EXISTS
            );
            return;
        }

        if (!rc.checkRole(_owner, rc.ROLE_PROVIDER())) {
            emit DataTokenMinted(
                _dt,
                _owner,
                msg.sender,
                _isLeaf,
                _checksum,
                _ipfsPath,
                block.number,
                rc.ERROR_NO_PERMISSION()
            );
            return;
        }

        // Owner of composable DT must be aggregator (enterprize now)
        if (!_isLeaf && !rc.checkRole(_owner, rc.ROLE_ENTERPRIZE())) {
            emit DataTokenMinted(
                _dt,
                _owner,
                msg.sender,
                _isLeaf,
                _checksum,
                _ipfsPath,
                block.number,
                rc.ERROR_NO_PERMISSION()
            );
            return;
        }

        DTLists[_dt] = DataToken({
            dt: _dt,
            owner: _owner,
            minter: msg.sender,
            isLeaf: _isLeaf,
            checksum: _checksum,
            ipfsPath: _ipfsPath,
            blockUpdated: block.number
        });

        if (_isLeaf) {
            dts.push(_dt);
        }

        emit DataTokenMinted(
            _dt,
            _owner,
            msg.sender,
            _isLeaf,
            _checksum,
            _ipfsPath,
            block.number,
            SUCCESS
        );
    }

    /**
     * @dev grantPermission
     *      It grants one dt to other dt.
     * @param _dt refers to data token identifier
     * @param _grantee refers to granted dt identifier
     */
    function grantPermission(bytes32 _dt, bytes32 _grantee) external {
        if (!rc.checkPermission(msg.sender, rc.MODIFY_AUTHORIZE())) {
            emit DataTokenGranted(
                _dt,
                msg.sender,
                _grantee,
                rc.ERROR_NO_PERMISSION()
            );
            return;
        }

        if (DTPermissions[_dt][_grantee] != false) {
            emit DataTokenGranted(_dt, msg.sender, _grantee, DT_GRATED);
            return;
        }

        if (!isDTAvailable(_dt) || !isDTAvailable(_grantee)) {
            emit DataTokenGranted(_dt, msg.sender, _grantee, DT_NOT_EXISTS);
            return;
        }

        if (DTLists[_dt].owner != msg.sender) {
            emit DataTokenGranted(
                _dt,
                msg.sender,
                _grantee,
                rc.ERROR_NO_PERMISSION()
            );
            return;
        }

        // grantee must be composable DT
        if (
            (!DTLists[_dt].isLeaf && !isCDTAvailable(_dt)) ||
            DTLists[_grantee].isLeaf
        ) {
            emit DataTokenGranted(_dt, msg.sender, _grantee, CDT_NOT_EXISTS);
            return;
        }

        DTPermissions[_dt][_grantee] = true;

        emit DataTokenGranted(_dt, msg.sender, _grantee, SUCCESS);
    }

    /**
     * @dev startComposeDT
     *      activates the CDT by the aggregator when all perms are ready.
     * @param _cdt refers to cdt identifier
     * @param _childDTs associated with child_dts identifier
     */
    function startComposeDT(bytes32 _cdt, bytes32[] memory _childDTs) public {
        if (!rc.checkPermission(msg.sender, rc.MODIFY_ASSET())) {
            emit CDTMinted(_cdt, _childDTs, rc.ERROR_NO_PERMISSION());
            return;
        }

        if (DTLists[_cdt].isLeaf) {
            emit CDTMinted(_cdt, _childDTs, rc.ERROR_NO_PERMISSION());
            return;
        }

        if (isCDTAvailable(_cdt)) {
            emit CDTMinted(_cdt, _childDTs, CDT_EXISTS);
            return;
        }

        if (DTLists[_cdt].owner != msg.sender) {
            emit CDTMinted(_cdt, _childDTs, rc.ERROR_NO_PERMISSION());
            return;
        }

        if (!CLinksCheck(_cdt, _childDTs)) {
            emit CDTMinted(_cdt, _childDTs, rc.ERROR_NO_PERMISSION());
        }

        CDTLists[_cdt] = true;
        
        dts.push(_cdt);

        emit CDTMinted(_cdt, _childDTs, SUCCESS);
    }

    /**
     * @dev CLinksCheck
     *      checks permission for related parties of a Composable DT.
     * @param _cdt refers to cdt identifier
     * @param _childDTs refers to child_dts identifiers
     * @return bool.
     */
    function CLinksCheck(bytes32 _cdt, bytes32[] memory _childDTs)
        public
        view
        returns (bool)
    {
        if (!isDTAvailable(_cdt)) {
            return false;
        }

        uint256 idx = 0;
        for (idx = 0; idx < _childDTs.length; idx++) {
            if (!isDTAvailable(_childDTs[idx])) {
                return false;
            }
            if (
                !DTLists[_childDTs[idx]].isLeaf &&
                !isCDTAvailable(_childDTs[idx])
            ) {
                return false;
            }
            if (!getPermission(_childDTs[idx], _cdt)) {
                return false;
            }
        }

        return true;
    }

    /**
     * @dev isDTAvailable
     * @param _dt refers to the dt identifier
     * @return bool.
     */
    function isDTAvailable(bytes32 _dt) public view returns (bool) {
        if (DTLists[_dt].dt != _dt) {
            return false;
        }
        return true;
    }

    /**
     * @dev isCDTAvailable
     * @param _cdt refers to the cdt identifier
     * @return bool.
     */
    function isCDTAvailable(bytes32 _cdt) public view returns (bool) {
        return CDTLists[_cdt];
    }

    /**
     * @dev getPermission
     *      check permission.
     * @param _dt refers to data token identifier
     * @param _grantee refers to granted dt identifier
     * @return is granted or not.
     */
    function getPermission(bytes32 _dt, bytes32 _grantee)
        public
        view
        returns (bool)
    {
        return DTPermissions[_dt][_grantee];
    }

    /**
     * @dev getDTOwner
     *      It returns the owner for a data token.
     * @param _dt refers to data token identifier
     * @return owner address.
     */
    function getDTOwner(bytes32 _dt) public view returns (address) {
        require(isDTAvailable(_dt));

        return DTLists[_dt].owner;
    }

    /**
     * @dev getBlockNumberUpdated
     *      It returns the blockUpdated for a data token.
     * @param _dt refers to data token identifier
     * @return blockUpdated.
     */
    function getBlockNumberUpdated(bytes32 _dt)
        public
        view
        returns (uint256 blockUpdated)
    {
        require(isDTAvailable(_dt));

        return DTLists[_dt].blockUpdated;
    }

    /**
     * @dev getDTRegister
     *      It returns the dt records.
     * @param _dt refers to data token identifier
     * @return DataToken struct.
     */
    function getDTRegister(bytes32 _dt)
        public
        view
        returns (
            address owner,
            address minter,
            bytes32 checksum,
            bool isLeaf,
            string memory ipfsPath,
            uint256 blockUpdated
        )
    {
        require(isDTAvailable(_dt));

        owner = DTLists[_dt].owner;
        minter = DTLists[_dt].minter;
        checksum = DTLists[_dt].checksum;
        isLeaf = DTLists[_dt].isLeaf;
        ipfsPath = DTLists[_dt].ipfsPath;
        blockUpdated = DTLists[_dt].blockUpdated;
    }

    /**
     * @dev getDTNum
     *      gets the total datatoken numbers.
     * @return uint256.
     */
    function getDTNum()
        public
        view
        returns (
            uint256 totalDTs
        )
    {
        totalDTs = dts.length;
    }

    /**
     * @dev getDTMapIdx
     *      gets all available dts.
     * @return bytes32[].
     */
    function getDTMapIdx()
        public
        view
        returns (
            bytes32[] memory dtmapidx
        )
    {
        dtmapidx = dts;
    }
}
