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
 * @title OpTemplate
 *
 * @dev OpTemplate provides trusted operations.
 */
contract OpTemplate {
    uint256 private constant SUCCESS = 0;
    uint256 private constant TEMPLATE_EXISTS = 3001;
    uint256 private constant TEMPLATE_NOT_EXISTS = 3002;

    struct Template {
        bytes32 tid;
        string name;
        address publisher;
        bytes32 checksum;
        string ipfsPath;
        uint256 blockUpdated;
    }

    mapping(bytes32 => Template) opTemplates;
    bytes32[] public tids;

    event TemplatePublished(
        bytes32 indexed _tid,
        string indexed _name,
        address _publisher,
        bytes32 _checksum,
        string _ipfsPath,
        uint256 _blockUpdated,
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
     * @dev publishTemplate
     *      creates new op template on-chain.
     * @param _tid refers to the op template identifier
     * @param _name refers to the op template name
     * @param _checksum checksum associated with tid/metadata
     * @param _ipfsPath referes to the metadata storage path
     */
    function publishTemplate(
        bytes32 _tid,
        string memory _name,
        bytes32 _checksum,
        string memory _ipfsPath
    ) public {
        if (!rc.checkPermission(msg.sender, rc.MODIFY_OP())) {
            emit TemplatePublished(
                _tid,
                _name,
                msg.sender,
                _checksum,
                _ipfsPath,
                block.number,
                rc.ERROR_NO_PERMISSION()
            );
            return;
        }
        if (isTemplateExist(_tid)) {
            emit TemplatePublished(
                _tid,
                _name,
                msg.sender,
                _checksum,
                _ipfsPath,
                block.number,
                TEMPLATE_EXISTS
            );
            return;
        }

        opTemplates[_tid] = Template({
            tid: _tid,
            name: _name,
            publisher: msg.sender,
            checksum: _checksum,
            ipfsPath: _ipfsPath,
            blockUpdated: block.timestamp
        });
        
        tids.push(_tid);

        emit TemplatePublished(
            _tid,
            _name,
            msg.sender,
            _checksum,
            _ipfsPath,
            block.number,
            SUCCESS
        );
    }

    /**
     * @dev updateTemplate
     *      update published op template on-chain.
     * @param _tid refers to the op template identifier
     * @param _name refers to the op template name
     * @param _checksum checksum associated with tid/metadata
     * @param _ipfsPath referes to the metadata storage path
     */
    function updateTemplate(
        bytes32 _tid,
        string memory _name,
        bytes32 _checksum,
        string memory _ipfsPath
    ) public {
        if (!rc.checkPermission(msg.sender, rc.MODIFY_OP())) {
            emit TemplatePublished(
                _tid,
                _name,
                msg.sender,
                _checksum,
                _ipfsPath,
                block.number,
                rc.ERROR_NO_PERMISSION()
            );
            return;
        }
        if (!isTemplateExist(_tid)) {
            emit TemplatePublished(
                _tid,
                _name,
                msg.sender,
                _checksum,
                _ipfsPath,
                block.number,
                TEMPLATE_NOT_EXISTS
            );
            return;
        }

        opTemplates[_tid] = Template({
            tid: _tid,
            name: _name,
            publisher: msg.sender,
            checksum: _checksum,
            ipfsPath: _ipfsPath,
            blockUpdated: block.timestamp
        });

        emit TemplatePublished(
            _tid,
            _name,
            msg.sender,
            _checksum,
            _ipfsPath,
            block.number,
            SUCCESS
        );
    }

    /**
     * @dev isTemplateExist
     *      checks template existence.
     * @param _tid refers to the address identifier
     * @return bool.
     */
    function isTemplateExist(bytes32 _tid) public view returns (bool) {
        return opTemplates[_tid].tid == _tid;
    }

    /**
     * @dev getBlockNumberUpdated
     *      It returns the blockUpdated for a template.
     * @param _tid refers to op template identifier
     * @return blockUpdated.
     */
    function getBlockNumberUpdated(bytes32 _tid)
        public
        view
        returns (uint256 blockUpdated)
    {
        require(isTemplateExist(_tid));

        return opTemplates[_tid].blockUpdated;
    }

    /**
     * @dev getTemplateById
     *      It returns the template records.
     * @param _tid refers to op template identifier
     * @return Template struct.
     */
    function getTemplateById(bytes32 _tid)
        public
        view
        returns (
            string memory name,
            address publisher,
            bytes32 checksum,
            string memory ipfsPath,
            uint256 blockUpdated
        )
    {
        require(isTemplateExist(_tid));

        name = opTemplates[_tid].name;
        publisher = opTemplates[_tid].publisher;
        checksum = opTemplates[_tid].checksum;
        ipfsPath = opTemplates[_tid].ipfsPath;
        blockUpdated = opTemplates[_tid].blockUpdated;
    }

    /**
     * @dev getTemplateNum
     *      gets the total template numbers.
     * @return uint256.
     */
    function getTemplateNum()
        public
        view
        returns (
            uint256 totalTemplates
        )
    {
        totalTemplates = tids.length;
    }
}
